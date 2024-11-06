#include <Wire.h>
#include <ArduinoRS485.h>            // RS485 library for communication
#include <LoRaWan-RAK4630.h>         // LoRa library for RAK4631
#include <SPI.h>

#define SEND_INTERVAL 900000         // 15 minutes in milliseconds
#define RS485_BAUDRATE 115200        // Baud rate for RS485 communication

float accumulatedLiters = 0;         // Accumulated water consumption in liters
unsigned long lastSendTime = 0;      // Track the last send time

// OTAA keys in MSB format
uint8_t nodeDeviceEUI[8] = {0xAC, 0x1F, 0x09, 0xFF, 0xFE, 0x06, 0x74, 0xB4};
uint8_t nodeAppEUI[8] = {0xB8, 0x27, 0xEB, 0xFF, 0xFE, 0x39, 0x00, 0x01};
uint8_t nodeAppKey[16] = {0x65, 0x7C, 0x3E, 0x71, 0xE2, 0xA4, 0x52, 0xC4, 0xEB, 0xA0, 0xAE, 0x08, 0x5A, 0x6B, 0x14, 0x2C};

// LoRaWAN parameters
DeviceClass_t g_CurrentClass = CLASS_A;
LoRaMacRegion_t g_CurrentRegion = LORAMAC_REGION_EU868;
lmh_confirm g_CurrentConfirm = LMH_UNCONFIRMED_MSG;
uint8_t gAppPort = LORAWAN_APP_PORT;

// Structure containing LoRaWAN parameters, needed for lmh_init()
static lmh_param_t lora_param_init = {
    LORAWAN_ADR_OFF,       // Adaptive Data Rate
    DR_3,                  // Data rate (DR_3 for optimal SF9 in EU)
    LORAWAN_PUBLIC_NETWORK, // Public network (1 for TTN or other public networks)
    3,                     // JOINREQ_NBTRIALS - number of join attempts
    TX_POWER_0,            // TX power
    LORAWAN_DUTYCYCLE_OFF  // Duty cycle
};

// Forward declaration of LoRa event handlers
static void lorawan_has_joined_handler(void);
static void lorawan_join_failed_handler(void);
static void lorawan_confirm_class_handler(DeviceClass_t Class);

// Callback structure for LoRaWAN event handlers
static lmh_callback_t lora_callbacks = {
    BoardGetBatteryLevel,
    BoardGetUniqueId,
    BoardGetRandomSeed,
    nullptr,                     // No receive handler as it's uplink-only
    lorawan_has_joined_handler,
    lorawan_confirm_class_handler,
    lorawan_join_failed_handler
};

// Buffer for LoRaWAN data
uint8_t lora_app_data_buffer[64];
lmh_app_data_t lora_app_data = {lora_app_data_buffer, 0, 0, 0, 0};

// Function to send accumulated water data over LoRa
void send_lora_frame()
{
    if (lmh_join_status_get() != LMH_SET)
    {
        Serial.println("Not joined to a network, trying later...");
        return;
    }

    // Prepare payload
    lora_app_data.port = gAppPort;
    // Convert accumulatedLiters to bytes
    memcpy(lora_app_data.buffer, &accumulatedLiters, sizeof(accumulatedLiters));
    lora_app_data.buffsize = sizeof(accumulatedLiters);

    lmh_error_status error = lmh_send(&lora_app_data, g_CurrentConfirm);
    if (error == LMH_SUCCESS)
    {
        Serial.printf("LoRa packet sent successfully. Accumulated Water Consumption: %.2f liters\n", accumulatedLiters);
        accumulatedLiters = 0; // Reset after sending
    }
    else
    {
        Serial.printf("LoRa send failed. Error code: %d\n", error);
    }
}

void setup()
{
    Serial.begin(115200);
    while (!Serial);

    // RS485 setup
    RS485.begin(RS485_BAUDRATE);

    // Turn on power for RS485 module
    pinMode(WB_IO2, OUTPUT);
    digitalWrite(WB_IO2, HIGH);
    delay(500);

    // Enable RS485 receive mode
    RS485.receive();

    // Set OTAA keys
    lmh_setDevEui(nodeDeviceEUI);
    lmh_setAppEui(nodeAppEUI);
    lmh_setAppKey(nodeAppKey);

    // Initialize LoRaWAN
    if (lmh_init(&lora_callbacks, lora_param_init, true, g_CurrentClass, g_CurrentRegion) != 0)
    {
        Serial.println("LoRa initialization failed!");
        while (1);
    }

    // Start Join procedure
    lmh_join();
    Serial.println("Joining LoRa network...");
}

void loop()
{
    // Simulate reading the flow rate from the flow meter
    float flowRateLPM = readFlowRate(); // Function to read flow rate in liters per minute
    float intervalSeconds = 1.0;        // Assume data is read every second for real-time accumulation

    // Calculate accumulated volume based on flow rate
    accumulatedLiters += (flowRateLPM / 60.0) * intervalSeconds;

    // Check if it's time to send data (every 15 minutes)
    if (millis() - lastSendTime > SEND_INTERVAL)
    {
        lastSendTime = millis();
        send_lora_frame(); // Send the accumulated water consumption
    }

    delay(1000); // Wait 1 second before the next reading
}

// Function to read flow rate from the flow meter via RS-485
float readFlowRate()
{
    uint8_t request[] = {0x01, 0x03, 0x00, 0x00, 0x00, 0x02}; // Example Modbus request (modify as needed)
    uint8_t response[7];

    RS485.write(request, sizeof(request));
    delay(100); // Allow time for the flow meter to respond

    if (RS485.available())
    {
        for (int i = 0; i < 7; i++)
        {
            response[i] = RS485.read();
        }

        // Extract and convert flow rate from response
        uint16_t flowRateRaw = (response[3] << 8) | response[4];
        float flowRateLPM = convertToLitersPerMinute(flowRateRaw);
        Serial.printf("Flow Rate: %.2f L/min\n", flowRateLPM);
        return flowRateLPM;
    }
    else
    {
        Serial.println("Failed to read flow rate");
        return 0.0;
    }
}

// Convert raw data to liters per minute based on calibration
float convertToLitersPerMinute(uint16_t rawValue)
{
    // Example conversion, adjust based on sensor's calibration specifications
    float minFlowRate = 0.0;
    float maxFlowRate = 100.0; // Example max flow rate in L/min
    uint16_t minRaw = 0x0000;
    uint16_t maxRaw = 0xFFFF;

    return ((float)(rawValue - minRaw) / (maxRaw - minRaw)) * (maxFlowRate - minFlowRate) + minFlowRate;
}

// LoRaWAN join success handler
static void lorawan_has_joined_handler(void)
{
    Serial.println("Successfully joined LoRa network with OTAA!");
    lmh_class_request(g_CurrentClass);
}

// LoRaWAN join failed handler
static void lorawan_join_failed_handler(void)
{
    Serial.println("LoRa join failed! Check EUI and Key settings or gateway proximity.");
    delay(10000);
    lmh_join();
}

// LoRaWAN class confirm handler
static void lorawan_confirm_class_handler(DeviceClass_t Class)
{
    Serial.printf("Switched to LoRaWAN class %c\n", "ABC"[Class]);
}
