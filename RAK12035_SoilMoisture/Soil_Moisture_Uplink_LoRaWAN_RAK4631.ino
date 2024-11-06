#include <Wire.h>
#include <RAK12035_SoilMoisture.h>
#include <LoRaWan-RAK4630.h>  // LoRa library for RAK4631
#include <SPI.h>

#define SOIL_MOISTURE_SENSOR_ADDR 0x20 // Default I2C address for RAK12035
#define SEND_INTERVAL 900000           // 15 minutes in milliseconds

RAK12035 soilMoistureSensor(SOIL_MOISTURE_SENSOR_ADDR);
uint8_t moisture;

unsigned long lastSendTime = 0;

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

// Function to send soil moisture data over LoRa
void send_lora_frame()
{
    if (lmh_join_status_get() != LMH_SET)
    {
        // Not joined, try again later
        Serial.println("Not joined to a network, trying later...");
        return;
    }

    // Prepare payload
    lora_app_data.port = gAppPort;
    lora_app_data.buffer[0] = moisture; // Send soil moisture value directly as 1 byte
    lora_app_data.buffsize = 1;

    lmh_error_status error = lmh_send(&lora_app_data, g_CurrentConfirm);
    if (error == LMH_SUCCESS)
    {
        Serial.printf("LoRa packet sent successfully. Moisture: %d%%\n", moisture);
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

    Wire.begin();
    soilMoistureSensor.setup(Wire);
    soilMoistureSensor.begin();

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
    // Check if it's time to send data
    if (millis() - lastSendTime > SEND_INTERVAL)
    {
        lastSendTime = millis();

        // Read soil moisture
        if (soilMoistureSensor.get_sensor_moisture(&moisture))
        {
            Serial.printf("Soil Moisture: %d%%\n", moisture);
            send_lora_frame(); // Send the moisture data over LoRa
        }
        else
        {
            Serial.println("Failed to read soil moisture");
        }
    }
}

// LoRaWAN join success handler
static void lorawan_has_joined_handler(void)
{
    Serial.println("Successfully joined LoRa network with OTAA!");

    // Optionally, request confirmation of the current class
    lmh_class_request(g_CurrentClass);
}

// LoRaWAN join failed handler
static void lorawan_join_failed_handler(void)
{
    Serial.println("LoRa join failed! Check EUI and Key settings or gateway proximity.");
    Serial.println("Retrying join in 10 seconds...");
    delay(10000);
    lmh_join(); // Retry join
}

// LoRaWAN class confirm handler
static void lorawan_confirm_class_handler(DeviceClass_t Class)
{
    Serial.printf("Switched to LoRaWAN class %c\n", "ABC"[Class]);
}
