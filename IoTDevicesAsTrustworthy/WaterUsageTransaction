#include <Arduino.h>
#include <LoRaWan-RAK4630.h>
#include <SPI.h>
#include <Wire.h>
#include <uECC.h>               // For ECDSA
#include <Keccak.h>             // For Keccak-256 hashing
#include "compress.h"           // Placeholder for compression library

// LoRaWAN definitions
lmh_app_data_t *app_data;
static bool send_data = true;

// Private definitions for LoRaWAN
#define LORAWAN_APP_DATA_BUFF_SIZE 64
#define LORAWAN_APP_INTERVAL 900000  // 15 minutes in milliseconds

static uint8_t m_lora_app_data_buffer[LORAWAN_APP_DATA_BUFF_SIZE];            
static lmh_app_data_t m_lora_app_data = {m_lora_app_data_buffer, 0, 0, 0, 0};

// Transaction structure
struct Transaction {
  uint32_t T_n;  // Nonce
  uint16_t T_p;  // Gas Price
  uint16_t T_g;  // Gas Limit
  uint8_t T_t[20];  // Recipient Address
  uint32_t T_v;  // Value (Water Usage)
  uint8_t T_d[64];  // Input Data (smart contract call)
  uint8_t T_w[32];  // Chain ID + Signature Recovery Identifier
  uint8_t T_r[32];  // r part of ECDSA signature
  uint8_t T_s[32];  // s part of ECDSA signature
};

// Private and public keys
uint8_t privateKey[32] = { /* Enter private key here */ };
uint8_t publicKey[64];

// Flow sensor settings
#define FLOW_SENSOR_PIN 2      // Pin connected to the water flow sensor pulse output
volatile uint32_t pulseCount = 0;
float flowRate = 0.0;
float totalLiters = 0.0;

// Pulse count per liter (Adjust based on the used flow meter specification)
const float pulsesPerLiter = 450.0;  // Replace with the actual value from the water flow mwter used

// Interrupt service routine to count pulses
void IRAM_ATTR pulseCounter() {
  pulseCount++;
}

// Function to calculate water usage from pulse count
void calculateFlowRate() {
  flowRate = (pulseCount / pulsesPerLiter);  // Convert pulses to liters
  totalLiters += flowRate;  // Accumulate total water usage
  pulseCount = 0;  // Reset pulse count after each calculation
}

// Function to generate Tw (Chain ID + Signature Recovery)
void generateTw(uint32_t chainID, uint8_t recoveryID, uint8_t *Tw) {
  // Clear the Tw buffer
  memset(Tw, 0, 32);  // Assuming Tw is 32 bytes (256 bits)

  // Encode the chainID in the first part of Tw (4 bytes, assuming 32-bit chainID)
  memcpy(Tw, &chainID, sizeof(chainID));

  // Set the recovery ID (we use 1 byte for this)
  Tw[sizeof(chainID)] = recoveryID;
}

// Helper function to encode the transaction
void encodeTransaction(Transaction &tx, uint8_t *encodedTx) {
  // Custom Recursive Length Prefix (RLP) encoding
  memcpy(encodedTx, &tx.T_n, sizeof(tx.T_n));  // Nonce
  memcpy(encodedTx + sizeof(tx.T_n), &tx.T_p, sizeof(tx.T_p));  // Gas Price
  memcpy(encodedTx + sizeof(tx.T_n) + sizeof(tx.T_p), &tx.T_g, sizeof(tx.T_g));  // Gas Limit
  memcpy(encodedTx + sizeof(tx.T_n) + sizeof(tx.T_p) + sizeof(tx.T_g), &tx.T_t, sizeof(tx.T_t));  // Recipient
  memcpy(encodedTx + sizeof(tx.T_n) + sizeof(tx.T_p) + sizeof(tx.T_g) + sizeof(tx.T_t), &tx.T_v, sizeof(tx.T_v));  // Value
  memcpy(encodedTx + sizeof(tx.T_n) + sizeof(tx.T_p) + sizeof(tx.T_g) + sizeof(tx.T_t) + sizeof(tx.T_v), &tx.T_d, sizeof(tx.T_d));  // Input Data
  memcpy(encodedTx + sizeof(tx.T_n) + sizeof(tx.T_p) + sizeof(tx.T_g) + sizeof(tx.T_t) + sizeof(tx.T_v) + sizeof(tx.T_d), &tx.T_w, sizeof(tx.T_w));  // Chain ID + Signature Recovery
  memcpy(encodedTx + sizeof(tx.T_n) + sizeof(tx.T_p) + sizeof(tx.T_g) + sizeof(tx.T_t) + sizeof(tx.T_v) + sizeof(tx.T_d) + sizeof(tx.T_w), &tx.T_r, sizeof(tx.T_r));  // r part of the signature
  memcpy(encodedTx + sizeof(tx.T_n) + sizeof(tx.T_p) + sizeof(tx.T_g) + sizeof(tx.T_t) + sizeof(tx.T_v) + sizeof(tx.T_d) + sizeof(tx.T_w) + sizeof(tx.T_r), &tx.T_s, sizeof(tx.T_s));  // s part of the signature
}

// Hashing function using Keccak-256
void hashTransaction(uint8_t *encodedTx, uint8_t *hash) {
  Keccak256 keccak;
  keccak.add(encodedTx, sizeof(encodedTx));
  keccak.getHash(hash);
}

// ECDSA signing function
void signTransaction(uint8_t *hash, uint8_t *signature) {
  uECC_sign(privateKey, hash, 32, signature, uECC_secp256k1());
}

// Function to compress the transaction using a dictionary-based method
void compressTransaction(uint8_t *encodedTx, uint8_t *compressedTx, uint16_t &compressedSize) {
  // Apply dictionary-based compression
  compressedSize = compress(encodedTx, sizeof(encodedTx), compressedTx);
}

// Function to send the compressed transaction via LoRaWAN
void sendCompressedTransaction(uint8_t *compressedTx, uint16_t compressedSize) {
  m_lora_app_data.port = 1;
  memcpy(m_lora_app_data.buffer, compressedTx, compressedSize);
  m_lora_app_data.buffsize = compressedSize;
  lmh_send(&m_lora_app_data, LMH_UNCONFIRMED_MSG);
}

// Main function for creating and sending a transaction with water usage
void sendTransaction() {
  // Create the transaction for water usage
  Transaction tx;
  tx.T_n = random(1, 100000);  // Nonce
  tx.T_p = 1;  // Gas Price
  tx.T_g = 21000;  // Gas Limit
  memcpy(tx.T_t, publicKey, 20);  // Recipient Address
  tx.T_v = (uint32_t)(totalLiters * 1000);  // Total water usage in milliliters

  // Transaction input data (e.g., function signature and parameters)
  strcpy((char *)tx.T_d, "WaterUsageTransaction");

  // Generate Tw (Chain ID + Signature Recovery)
  generateTw(421614, 0, tx.T_w);  // Chain ID = 421614, Recovery ID = 0

  // Encode transaction
  uint8_t encodedTx[256];
  encodeTransaction(tx, encodedTx);

  // Hash the transaction
  uint8_t hash[32];
  hashTransaction(encodedTx, hash);

  // Sign the transaction
  uint8_t signature[64];
  signTransaction(hash, signature);
  memcpy(tx.T_r, signature, 32);  // r part
  memcpy(tx.T_s, signature + 32, 32);  // s part

  // Compress the transaction
  uint8_t compressedTx[128];
  uint16_t compressedSize;
  compressTransaction(encodedTx, compressedTx, compressedSize);

  // Send the compressed transaction via LoRaWAN
  sendCompressedTransaction(compressedTx, compressedSize);

  // Reset total liters for the next interval
  totalLiters = 0;
}

void setup() {
  // Initialize serial communication
  Serial.begin(115200);
  
  // Setup LoRaWAN
  lora_rak4630_init();
  while (!Serial);

  // Start LoRaWAN
  lmh_init(NULL, g_lora_param_init, true, CLASS_A, LORAMAC_REGION_EU868);
  lmh_setDevEui(nodeDeviceEUI);
  lmh_setAppEui(nodeAppEUI);
  lmh_setAppKey(nodeAppKey);
  lmh_join();

  // Setup water flow sensor
  pinMode(FLOW_SENSOR_PIN, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(FLOW_SENSOR_PIN), pulseCounter, FALLING);  // Attach interrupt to count pulses
}

void loop() {
  static unsigned long lastTransmissionTime = 0;
  
  // Check if 15 minutes (900000 ms) have passed
  if (millis() - lastTransmissionTime >= LORAWAN_APP_INTERVAL) {
    // Calculate total water usage in the interval
    calculateFlowRate();
    
    // Send water usage (even if 0)
    sendTransaction();
    
    // Update the last transmission time
    lastTransmissionTime = millis();
  }
}
