# Smart Bag Control App

A Flutter mobile application for controlling a smart bag with fingerprint authentication, Bluetooth communication with Arduino Mega, and comprehensive monitoring features.

## Features

### 🔐 Authentication
- **Fingerprint Authentication**: Secure access using device fingerprint scanner
- **PIN Fallback**: 4-digit admin PIN as backup authentication method
- **Biometric Support**: Compatible with Android 11+ biometric systems

### 🎒 Smart Bag Control
- **Umbrella Control**: Open/close umbrella with touch controls
- **Emergency Mode**: Quick emergency umbrella deployment
- **Real-time Monitoring**: Live status updates from smart bag sensors

### 📊 Monitoring Dashboard
- **Battery Level**: Real-time battery status monitoring
- **Temperature Sensor**: Environmental temperature tracking
- **Rain Level**: Precipitation detection and monitoring
- **Connection Status**: Bluetooth connectivity indicator

### ⚙️ Admin Functions
- **PIN Management**: Change admin PIN with Arduino Mega sync
- **SMS Configuration**: Update emergency SMS number
- **Bluetooth Pairing**: Easy device discovery and connection
- **Settings Management**: App preferences and configurations

### 🔗 Bluetooth Communication
- **Arduino Mega Integration**: Direct communication with smart bag controller
- **Auto-reconnect**: Automatic connection to last paired device
- **Data Sync**: Real-time data exchange with smart bag sensors

## Requirements

### System Requirements
- **Android**: Android 11 or higher
- **Bluetooth**: Bluetooth 4.0+ (BLE) support
- **Fingerprint**: Device with fingerprint sensor
- **Storage**: 50MB free space

### Hardware Requirements
- **Smart Bag**: Arduino Mega with Bluetooth module
- **Sensors**: Battery, temperature, rain level sensors
- **Actuators**: Umbrella control mechanism
- **Bluetooth Module**: HC-05 or similar for Arduino communication

## Installation

### Prerequisites
1. **Flutter SDK**: Install Flutter 3.10.0 or higher
2. **Android Studio**: Latest version with Android SDK
3. **Android Device**: Physical device for testing (recommended)

### Build Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd smart_bag_control
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Build for Android**
   ```bash
   flutter build apk --release
   ```

4. **Install on device**
   ```bash
   flutter install
   ```

### Development Setup

1. **Enable developer options** on your Android device
2. **Enable USB debugging**
3. **Connect device** via USB
4. **Run in debug mode**
   ```bash
   flutter run
   ```

## Usage

### First Time Setup

1. **Launch the app**
2. **Grant permissions** when prompted:
   - Bluetooth permissions
   - Location permissions
   - Fingerprint permissions

3. **Setup Admin PIN** (if not already set)
   - Enter a 4-digit PIN
   - Confirm the PIN
   - PIN will be synced with Arduino Mega

4. **Connect to Smart Bag**
   - Navigate to Bluetooth settings
   - Scan for your smart bag device
   - Tap to connect

### Daily Usage

1. **Authentication**
   - Use fingerprint or PIN to unlock
   - App remembers authentication state

2. **Monitor Status**
   - View battery level, temperature, rain level
   - Check umbrella status (open/closed)

3. **Control Umbrella**
   - Tap "Open Umbrella" or "Close Umbrella"
   - Use emergency mode for quick deployment

4. **Admin Functions**
   - Access admin settings for PIN/SMS changes
   - All changes sync with Arduino Mega

## Arduino Mega Integration

### Required Components
- Arduino Mega 2560
- HC-05 Bluetooth module
- Battery level sensor
- Temperature sensor (DHT22/DHT11)
- Rain sensor
- Servo motor for umbrella control
- Power management circuit

### Communication Protocol

The app communicates with Arduino Mega using JSON messages:

```json
// Commands sent to Arduino
{
  "command": "OPEN_UMBRELLA"
}

{
  "command": "SET_PIN",
  "value": "1234"
}

{
  "command": "SET_SMS",
  "value": "+1234567890"
}

// Data received from Arduino
{
  "battery": 85,
  "temperature": 23.5,
  "rain": 0,
  "umbrella": false,
  "pin": "1234",
  "sms": "+1234567890"
}
```

### Arduino Code Structure

```cpp
#include <SoftwareSerial.h>
#include <ArduinoJson.h>

// Bluetooth module
SoftwareSerial bluetooth(2, 3);

// Sensors
const int BATTERY_PIN = A0;
const int TEMP_PIN = 4;
const int RAIN_PIN = 5;
const int SERVO_PIN = 9;

// Variables
int batteryLevel = 0;
float temperature = 0.0;
int rainLevel = 0;
bool umbrellaOpen = false;
String adminPin = "0000";
String smsNumber = "";

void setup() {
  Serial.begin(9600);
  bluetooth.begin(9600);
  
  // Initialize sensors and actuators
  pinMode(RAIN_PIN, INPUT);
  servo.attach(SERVO_PIN);
}

void loop() {
  // Read sensor data
  readSensors();
  
  // Check for Bluetooth commands
  if (bluetooth.available()) {
    String command = bluetooth.readString();
    processCommand(command);
  }
  
  // Send status data
  sendStatusData();
  
  delay(1000);
}

void processCommand(String command) {
  // Parse JSON command and execute
  // Handle umbrella control, PIN updates, SMS updates
}

void sendStatusData() {
  // Create JSON with sensor data and send via Bluetooth
}
```

## Permissions

The app requires the following permissions:

- **BLUETOOTH**: For device communication
- **BLUETOOTH_SCAN**: For device discovery
- **BLUETOOTH_CONNECT**: For device connection
- **ACCESS_FINE_LOCATION**: Required for Bluetooth scanning
- **USE_BIOMETRIC**: For fingerprint authentication
- **INTERNET**: For potential cloud features

## Troubleshooting

### Common Issues

1. **Bluetooth not connecting**
   - Ensure smart bag is powered on
   - Check Bluetooth module is in pairing mode
   - Verify device is within range (10m)

2. **Fingerprint not working**
   - Check device has fingerprint sensor
   - Ensure fingerprint is registered in device settings
   - Try PIN authentication as fallback

3. **App crashes on startup**
   - Grant all required permissions
   - Restart app after permission grant
   - Check Android version compatibility

4. **Data not updating**
   - Verify Bluetooth connection is active
   - Check Arduino Mega is sending data
   - Restart Bluetooth connection

### Debug Mode

Enable debug logging:
```bash
flutter run --debug
```

Check logs for detailed error information.

## Security Features

- **Fingerprint Authentication**: Biometric security
- **PIN Protection**: 4-digit admin PIN
- **Secure Communication**: Bluetooth encryption
- **Data Validation**: Input sanitization
- **Session Management**: Automatic logout

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For technical support or feature requests, please open an issue on the repository.

---

**Smart Bag Control App** - Control your smart bag with ease and security.