/*
 * Smart Bag Controller - Arduino Mega Code
 * 
 * This code handles communication with the Flutter mobile app via Bluetooth
 * and controls various smart bag features including umbrella, lock, and sensors.
 * 
 * Hardware Requirements:
 * - Arduino Mega 2560
 * - HC-05/HC-06 Bluetooth module (connected to Serial1)
 * - Fingerprint sensor (R307/R308)
 * - DHT11/DHT22 temperature sensor
 * - Rain sensor
 * - Servo motor for umbrella control
 * - Solenoid lock for bag security
 * - Battery voltage divider circuit
 */

#include <SoftwareSerial.h>
#include <Adafruit_Fingerprint.h>
#include <DHT.h>
#include <Servo.h>

// Pin definitions
#define FINGERPRINT_RX 2
#define FINGERPRINT_TX 3
#define DHT_PIN 4
#define RAIN_SENSOR_PIN 5
#define BATTERY_PIN A0
#define SERVO_PIN 6
#define LOCK_PIN 7
#define DHT_TYPE DHT11

// Bluetooth communication
SoftwareSerial bluetooth(10, 11); // RX, TX
Adafruit_Fingerprint finger = Adafruit_Fingerprint(&Serial2);
DHT dht(DHT_PIN, DHT_TYPE);
Servo umbrellaServo;

// Global variables
String adminPin = "1234";
String smsNumber = "+1234567890";
bool umbrellaOpen = false;
bool bagLocked = true;
int batteryLevel = 0;
float temperature = 0;
int rainLevel = 0;

void setup() {
  // Initialize serial communications
  Serial.begin(9600);
  bluetooth.begin(9600);
  
  // Initialize sensors and actuators
  finger.begin(57600);
  dht.begin();
  umbrellaServo.attach(SERVO_PIN);
  
  // Set pin modes
  pinMode(RAIN_SENSOR_PIN, INPUT);
  pinMode(LOCK_PIN, OUTPUT);
  pinMode(BATTERY_PIN, INPUT);
  
  // Initialize states
  umbrellaServo.write(0); // Close umbrella
  digitalWrite(LOCK_PIN, HIGH); // Lock bag
  
  // Read initial sensor values
  updateSensors();
  
  Serial.println("Smart Bag Controller initialized");
  bluetooth.println("STATUS:READY");
}

void loop() {
  // Check for incoming Bluetooth commands
  if (bluetooth.available()) {
    String command = bluetooth.readStringUntil('\n');
    command.trim();
    processCommand(command);
  }
  
  // Update sensors periodically
  static unsigned long lastSensorUpdate = 0;
  if (millis() - lastSensorUpdate > 5000) { // Update every 5 seconds
    updateSensors();
    lastSensorUpdate = millis();
  }
  
  delay(100);
}

void processCommand(String command) {
  Serial.println("Received: " + command);
  
  if (command == "UMBRELLA_OPEN") {
    openUmbrella();
  }
  else if (command == "UMBRELLA_CLOSE") {
    closeUmbrella();
  }
  else if (command == "LOCK_BAG") {
    lockBag();
  }
  else if (command == "UNLOCK_BAG") {
    unlockBag();
  }
  else if (command == "GET_BATTERY") {
    sendBatteryLevel();
  }
  else if (command == "GET_TEMP") {
    sendTemperature();
  }
  else if (command == "GET_RAIN") {
    sendRainLevel();
  }
  else if (command == "GET_STATUS") {
    sendStatus();
  }
  else if (command.startsWith("SET_ADMIN_PIN:")) {
    setAdminPin(command.substring(14));
  }
  else if (command.startsWith("SET_SMS:")) {
    setSmsNumber(command.substring(8));
  }
  else {
    bluetooth.println("ERROR:Unknown command");
  }
}

void openUmbrella() {
  umbrellaServo.write(180);
  umbrellaOpen = true;
  bluetooth.println("UMBRELLA:OPEN");
  Serial.println("Umbrella opened");
}

void closeUmbrella() {
  umbrellaServo.write(0);
  umbrellaOpen = false;
  bluetooth.println("UMBRELLA:CLOSE");
  Serial.println("Umbrella closed");
}

void lockBag() {
  digitalWrite(LOCK_PIN, HIGH);
  bagLocked = true;
  bluetooth.println("LOCK:LOCKED");
  Serial.println("Bag locked");
}

void unlockBag() {
  digitalWrite(LOCK_PIN, LOW);
  bagLocked = false;
  bluetooth.println("LOCK:UNLOCKED");
  Serial.println("Bag unlocked");
}

void updateSensors() {
  // Read battery level (assuming voltage divider)
  int batteryRaw = analogRead(BATTERY_PIN);
  batteryLevel = map(batteryRaw, 0, 1023, 0, 100);
  
  // Read temperature
  temperature = dht.readTemperature();
  if (isnan(temperature)) {
    temperature = 0;
  }
  
  // Read rain level
  int rainRaw = analogRead(RAIN_SENSOR_PIN);
  rainLevel = map(rainRaw, 0, 1023, 0, 100);
}

void sendBatteryLevel() {
  bluetooth.print("BAT:");
  bluetooth.println(batteryLevel);
}

void sendTemperature() {
  bluetooth.print("TEMP:");
  bluetooth.println(temperature);
}

void sendRainLevel() {
  bluetooth.print("RAIN:");
  bluetooth.println(rainLevel);
}

void sendStatus() {
  bluetooth.println("STATUS:OK");
}

void setAdminPin(String pin) {
  if (pin.length() == 4 && pin.toInt() > 0) {
    adminPin = pin;
    bluetooth.println("STATUS:Admin PIN updated");
    Serial.println("Admin PIN updated to: " + pin);
  } else {
    bluetooth.println("ERROR:Invalid PIN format");
  }
}

void setSmsNumber(String number) {
  if (number.length() >= 10) {
    smsNumber = number;
    bluetooth.println("STATUS:SMS number updated");
    Serial.println("SMS number updated to: " + number);
  } else {
    bluetooth.println("ERROR:Invalid phone number");
  }
}

// Fingerprint functions (if using fingerprint sensor)
bool verifyFingerprint() {
  uint8_t p = finger.getImage();
  if (p != FINGERPRINT_OK) return false;
  
  p = finger.image2Tz();
  if (p != FINGERPRINT_OK) return false;
  
  p = finger.fingerFastSearch();
  if (p != FINGERPRINT_OK) return false;
  
  return true;
}

// Helper function to send sensor data periodically
void sendSensorData() {
  sendBatteryLevel();
  sendTemperature();
  sendRainLevel();
}