#include <Arduino.h>
#include <LoRaWan-RAK4630.h> //http://librarymanager/All#SX126x
#include <SPI.h>
#include <Wire.h>
#include "Adafruit_MCP23X17.h"  //http://librarymanager/All#Adafruit_MCP23017//

lmh_app_data_t *app_data;
static lmh_app_data_t received_data;
static bool new_data_received = false;
static bool Open_Serial = false;
// unsigned long timer0 = millis();

// RAK4630 supply two LED
#ifndef LED_BUILTIN
#define LED_BUILTIN 35
#endif

#ifndef LED_BUILTIN2
#define LED_BUILTIN2 36
#endif

#define PAIN_PBOUT //PB is set as output here and PA as input.
Adafruit_MCP23X17 mcp;

bool doOTAA = true;   // OTAA is used by default.
#define SCHED_MAX_EVENT_DATA_SIZE APP_TIMER_SCHED_EVENT_DATA_SIZE /**< Maximum size of scheduler events. */
#define SCHED_QUEUE_SIZE 60										  /**< Maximum number of events in the scheduler queue. */
#define LORAWAN_DATERATE DR_3									  /*LoRaMac datarates definition, from DR_0 to DR_5*/ // DR_3 ==> the spreading factor equal to 9 (optimal value)
#define LORAWAN_TX_POWER TX_POWER_0							/*LoRaMac tx power definition, from TX_POWER_0 to TX_POWER_15*/ // TX Power 0 is the strongest signal & TX Power 15 is the weakest signal
#define JOINREQ_NBTRIALS 3										  /**< Number of trials for the join request. */

bool send_data = true;
bool local_control = true;
bool Pump_Status = false;
bool BtnAuto, LedGreen, RelayAuto;

DeviceClass_t g_CurrentClass = CLASS_C;				             /* class definition*/
LoRaMacRegion_t g_CurrentRegion = LORAMAC_REGION_EU868;    /* Region:EU868*/
lmh_confirm g_CurrentConfirm = LMH_UNCONFIRMED_MSG;				 /* confirm/unconfirm packet definition*/
uint8_t gAppPort = LORAWAN_APP_PORT;							         /* data port*/

/**@brief Structure containing LoRaWan parameters, needed for lmh_init() */
static lmh_param_t g_lora_param_init = {LORAWAN_ADR_OFF, LORAWAN_DATERATE, LORAWAN_PUBLIC_NETWORK, JOINREQ_NBTRIALS, LORAWAN_TX_POWER, LORAWAN_DUTYCYCLE_OFF};

// Forward declaration
static void lorawan_has_joined_handler(void);
static void lorawan_join_failed_handler(void);
static void lorawan_rx_handler(lmh_app_data_t *app_data);
static void lorawan_confirm_class_handler(DeviceClass_t Class);
static void send_lora_frame(void);

/**@brief Structure containing LoRaWan callback functions, needed for lmh_init() */
static lmh_callback_t g_lora_callbacks = {BoardGetBatteryLevel, BoardGetUniqueId, BoardGetRandomSeed,
                                        lorawan_rx_handler, lorawan_has_joined_handler, lorawan_confirm_class_handler, lorawan_join_failed_handler
                                       };
//OTAA keys !!!! KEYS ARE MSB !!!!
uint8_t nodeDeviceEUI[8] = {0xAC, 0x1F, 0x09, 0xFF, 0xFE, 0x06, 0x74, 0xB4};
uint8_t nodeAppEUI[8] = {0xB8,0x27,0xEB,0xFF,0xFE,0x39,0x00,0x01};
uint8_t nodeAppKey[16] = {0x65,0x7C,0x3E,0x71,0xE2,0xA4,0x52,0xC4,0xEB,0xA0,0xAE,0x08,0x5A,0x6B,0x14,0x2C};

// Private defination
#define LORAWAN_APP_DATA_BUFF_SIZE 64                     /**< buffer size of the data to be transmitted. */
#define LORAWAN_APP_INTERVAL 20000                        /**< Defines for user timer, the application data transmission interval. 20s, value in [ms]. */
static uint8_t m_lora_app_data_buffer[LORAWAN_APP_DATA_BUFF_SIZE];            //< Lora user application data buffer.
static lmh_app_data_t m_lora_app_data = {m_lora_app_data_buffer, 0, 0, 0, 0}; //< Lora user application data structure.

TimerEvent_t appTimer;
static uint32_t timers_init(void);
static uint32_t count = 0;
static uint32_t count_fail = 0;

void setup()
{
  // Used for 3V3_S enable 
  pinMode(WB_IO2, OUTPUT);
  digitalWrite(WB_IO2, 1);
  
  // Reset device
  pinMode(WB_IO4, OUTPUT);
  digitalWrite(WB_IO4, 1);
  delay(10);
  digitalWrite(WB_IO4, 0);
  delay(10);
  digitalWrite(WB_IO4, 1);
  delay(10);

  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);

  // Initialize Serial for debug output
  time_t timeout = millis();
  Serial.begin(115200);
  while (!Serial)
  {
    if ((millis() - timeout) < 5000)
    {
      delay(100);
    }
    else
    {
      break;
    }
  }

  Serial.println("MCP23017 GPIO Input Output Test.");
  mcp.begin_I2C(); // use default address 0.

  mcp.pinMode(0, INPUT_PULLUP);  // Set GPIO to input mode with internal pullup resistor ON PA0 AUTO
  mcp.pinMode(2, INPUT_PULLUP);//INPUT ON/OFF PA2

  mcp.pinMode(8, OUTPUT);
  mcp.pinMode(10, OUTPUT);
  mcp.pinMode(12, OUTPUT);
  //Init Local IHM
  Serial.println(F("Start init Local IHM..."));
  mcp.digitalWrite(8, HIGH);  // PIN PA0 : RelayStop
  mcp.digitalWrite(10, HIGH); //PIN PA2 : RelayStart
  mcp.digitalWrite(12, HIGH);  //PIN PB4 : RelayAuto
  Serial.println(F("Local IHM init OK!"));

  // Initialize LoRa chip.
  lora_rak4630_init();

  Serial.println("=====================================");
  Serial.println("Welcome to RAK4630 LoRaWan!!!");
  Serial.println("=====================================");
  
  //creat a user timer to send data to server period // OTAA Mode, Network Joined!
  uint32_t err_code;
  err_code = timers_init();
  if (err_code != 0)
  {
    Serial.printf("timers_init failed - %d\n", err_code);
    return;
  }

  // Setup the EUIs and Keys
  if (doOTAA)
  {
    lmh_setDevEui(nodeDeviceEUI);
    lmh_setAppEui(nodeAppEUI);
    lmh_setAppKey(nodeAppKey);
  }

  // Initialize LoRaWan
  err_code = lmh_init(&g_lora_callbacks, g_lora_param_init, doOTAA, g_CurrentClass, g_CurrentRegion);
  if (err_code != 0)
  {
    Serial.printf("lmh_init failed - %d\n", err_code);
    return;
  }

  // Start Join procedure
  lmh_join();
}

void loop()
{  
  // if (millis() - timer0 >= 540000){  // wait 9 min
  //   timer0 = millis();
  //   send_data=true;
  // }
  
  // Send Local IHM State...
  send_data=true;
  for (unsigned long start = millis(); millis() - start < 540000L;)   // wait 9 min
  { 
    // Serial.parseInt(); //command like button in this case
    BtnAuto = mcp.digitalRead(0);
    LedGreen = mcp.digitalRead(2);  
    
    lorawan_rx_handler(app_data);
    if (Open_Serial) {
     delay(1);        
    }

    String downcommand=(char *)(received_data.buffer);
    if(downcommand=="0011"){
      Serial.println("Remote Stop: Manual Mode");
      mcp.digitalWrite(8, LOW);   // RelayStop 
      delay(200);
      mcp.digitalWrite(8, HIGH);   // RelayStop  
      mcp.digitalWrite(12, HIGH); // RelayAuto      
      RelayAuto = false;
    }
    if(downcommand=="0100"){
      Serial.println("Remote Start: Manual Mode"); 
      mcp.digitalWrite(10, LOW);  // RelayStart
      delay(200);
      mcp.digitalWrite(10, HIGH);  // RelayStart
      mcp.digitalWrite(12, HIGH); // RelayAuto             
      RelayAuto = false;
    }
    if(downcommand=="0101"){
      Serial.println("Activate Automatic Mode"); 
      mcp.digitalWrite(12, LOW);
      RelayAuto = true;               
    }
    if(downcommand=="0110"){
      Serial.println("Auto OFF"); // Automatic Mode
      mcp.digitalWrite(8, LOW);   // RelayStop 
      delay(200);
      mcp.digitalWrite(8, HIGH);   // RelayStop        
      mcp.digitalWrite(12, LOW);   // RelayAuto
      RelayAuto = true;              
    }
    if(downcommand=="0111"){
      Serial.println("Auto ON");  // Automatic Mode
      mcp.digitalWrite(10, LOW);  // RelayStart 
      delay(200);
      mcp.digitalWrite(10, HIGH);  // RelayStart      
      mcp.digitalWrite(12, LOW);  // RelayAuto            
      RelayAuto = true;  
    }
  
    if(new_data_received == true){
      local_control=false;
      Serial.printf("LoRa Packet received on port %d, size:%d, rssi:%d, snr:%d, data:%s\n",
          received_data.port, received_data.buffsize, received_data.rssi, received_data.snr,received_data.buffer); 
      //delay(200);
      LedGreen = mcp.digitalRead(2);
      Pump_Status = LedGreen;
      send_data=true; 
      new_data_received = false; 
    } 

    if(new_data_received == false) {    
      // Uplink 
      if (Pump_Status != LedGreen) {
        Pump_Status = LedGreen; 
        local_control = true;
        RelayAuto = false;
        mcp.digitalWrite(12, HIGH);  // RelayAuto
        Serial.println("Local Control: Manual Mode");
        send_data=true;
      }
      
      if (BtnAuto == false)
      {
        local_control=true;
        mcp.digitalWrite(8, HIGH); // Relay Stop 
        mcp.digitalWrite(12, LOW); // Relay Auto       
        Serial.println("Automatic Mode");
        send_data=true; 
        while(mcp.digitalRead(0) == false){          
        }   
      }
    }
  }    
}

/**@brief LoRa function for handling HasJoined event. */
void lorawan_has_joined_handler(void)
{
  if(doOTAA == true)
  {
  Serial.println("OTAA Mode, Network Joined!");
  }
  else
  {
    Serial.println("ABP Mode");
  }

  lmh_error_status ret = lmh_class_request(g_CurrentClass);
  if (ret == LMH_SUCCESS)
  {
    delay(1000);
    TimerSetValue(&appTimer, LORAWAN_APP_INTERVAL);
    TimerStart(&appTimer);
  }
}
/**@brief LoRa function for handling OTAA join failed */
static void lorawan_join_failed_handler(void)
{
  Serial.println("OTAA join failed!");
  Serial.println("Check your EUI's and Keys's!");
  Serial.println("Check if a Gateway is in range!");
}
/**@brief Function for handling LoRaWan received data from Gateway
 *
 * @param[in] app_data  Pointer to rx data
 */
void lorawan_rx_handler(lmh_app_data_t *app_data)
{
  received_data = *app_data; // store received data in global variable
  Open_Serial = true;
  if (received_data.port == 1 && received_data.buffsize == 4) {
    new_data_received = true;  
  }  
}

void lorawan_confirm_class_handler(DeviceClass_t Class)
{
  Serial.printf("switch to class %c done\n", "ABC"[Class]);
  // Informs the server that switch has occurred ASAP
  m_lora_app_data.buffsize = 0;
  m_lora_app_data.port = gAppPort;
  lmh_send(&m_lora_app_data, g_CurrentConfirm);
}

void send_lora_frame(void)
{
  if (lmh_join_status_get() != LMH_SET)
  {
    //Not joined, try again later
    return;
  }
  
  uint32_t i = 0;
  memset(m_lora_app_data.buffer, 0, LORAWAN_APP_DATA_BUFF_SIZE);
  m_lora_app_data.port = gAppPort;
  m_lora_app_data.buffer[i++] = 0x01;
  m_lora_app_data.buffer[i++] = (uint8_t)(LedGreen >> 8);
  m_lora_app_data.buffer[i++] = (uint8_t)LedGreen;
  m_lora_app_data.buffer[i++] = (uint8_t)(RelayAuto >> 8);
  m_lora_app_data.buffer[i++] = (uint8_t)RelayAuto;
  m_lora_app_data.buffer[i++] = (uint8_t)(local_control >> 8);
  m_lora_app_data.buffer[i++] = (uint8_t)local_control;  
  m_lora_app_data.buffsize = i;

  lmh_error_status error = lmh_send(&m_lora_app_data, g_CurrentConfirm);
  if (error == LMH_SUCCESS)
  {
    count++;
    send_data=false;
    Serial.printf("lmh_send ok count %d\n", count);
  }
  else
  {
    count_fail++;
    Serial.printf("lmh_send fail count %d\n", count_fail);
  }
}

/**@brief Function for handling user timerout event. */
void tx_lora_periodic_handler(void)
{
  TimerSetValue(&appTimer, LORAWAN_APP_INTERVAL);
  TimerStart(&appTimer);
  
  if(send_data){
  Serial.println("Sending frame now...");
  send_lora_frame();
  }
}

/**@brief Function for the Timer initialization.
 *
 * @details Initializes the timer module. This creates and starts application timers. */
uint32_t timers_init(void)
{
  TimerInit(&appTimer, tx_lora_periodic_handler);
  return 0;
}
