# Smart Bag Controller

A Flutter mobile application for controlling a smart bag with fingerprint authentication, Bluetooth connectivity, and real-time sensor monitoring.

## Features

### 🔐 Security
- **Fingerprint Authentication**: Secure access to bag controls using device fingerprint scanner
- **Admin PIN Management**: Set and change admin PIN with fingerprint verification
- **SMS Alert Configuration**: Configure phone number for SMS alerts

### 📱 Smart Controls
- **Umbrella Control**: Open/close umbrella with fingerprint authentication
- **Bag Lock/Unlock**: Secure bag locking mechanism
- **Real-time Monitoring**: Live sensor data display

### 📊 Sensor Monitoring
- **Battery Level**: Monitor bag battery status with visual indicators
- **Temperature**: Real-time temperature monitoring
- **Rain Level**: Rain detection and monitoring
- **Status Updates**: Automatic sensor data refresh

### 🔗 Connectivity
- **Bluetooth LE**: Connect to Arduino Mega via Bluetooth module
- **Device Discovery**: Automatic smart bag device scanning
- **Connection Management**: Easy connect/disconnect functionality

## Requirements

### Mobile App
- Android 11+ (API level 30+)
- Flutter 3.0+
- Bluetooth LE support
- Fingerprint scanner hardware

### Hardware (Smart Bag)
- Arduino Mega 2560
- HC-05/HC-06 Bluetooth module
- Fingerprint sensor (R307/R308)
- Temperature sensor (DHT11/DHT22)
- Rain sensor
- Battery level monitoring circuit
- Servo motors for umbrella control
- Solenoid lock for bag security

## Installation

### Prerequisites
1. Install Flutter SDK (3.0 or higher)
2. Install Android Studio
3. Set up Android SDK (API 30+)
4. Enable developer options on Android device

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd smart_bag_controller
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Android permissions**
   - The app will request necessary permissions on first launch
   - Grant Bluetooth, Location, and Biometric permissions

4. **Build and install**
   ```bash
   flutter build apk --release
   flutter install
   ```

## Arduino Code Requirements

The Arduino Mega should implement the following communication protocol:

### Commands from App to Arduino
```
UMBRELLA_OPEN\n      # Open umbrella
UMBRELLA_CLOSE\n     # Close umbrella
LOCK_BAG\n          # Lock bag
UNLOCK_BAG\n        # Unlock bag
GET_BATTERY\n       # Request battery level
GET_TEMP\n          # Request temperature
GET_RAIN\n          # Request rain level
SET_ADMIN_PIN:1234\n # Set admin PIN
SET_SMS:+1234567890\n # Set SMS number
GET_STATUS\n        # Request status
```

### Responses from Arduino to App
```
BAT:85.5\n          # Battery level (0-100%)
TEMP:23.4\n         # Temperature in Celsius
RAIN:15.2\n         # Rain level (0-100%)
UMBRELLA:OPEN\n     # Umbrella status
LOCK:LOCKED\n       # Lock status
STATUS:OK\n         # General status
```

## Usage

### Initial Setup
1. Launch the app
2. Grant necessary permissions when prompted
3. Tap the Bluetooth icon to scan for devices
4. Select your smart bag device and connect
5. Use fingerprint to authenticate for controls

### Daily Use
1. **Connect to Bag**: Tap Bluetooth icon and select your bag
2. **Monitor Sensors**: View real-time battery, temperature, and rain data
3. **Control Umbrella**: Tap umbrella button and authenticate with fingerprint
4. **Lock/Unlock Bag**: Tap lock button and authenticate with fingerprint
5. **Admin Settings**: Access via menu to configure PIN and SMS

### Admin Functions
- **Set Admin PIN**: 4-digit PIN for administrative access
- **Configure SMS**: Phone number for alert notifications
- **Fingerprint Required**: All admin changes require fingerprint authentication

## Permissions

The app requires the following permissions:

- **Bluetooth**: Connect to smart bag
- **Location**: Required for Bluetooth scanning (Android requirement)
- **Biometric**: Fingerprint authentication
- **SMS**: Send alert messages (admin feature)
- **Internet**: Future cloud features

## Troubleshooting

### Connection Issues
- Ensure Bluetooth is enabled on both devices
- Check that smart bag is powered on and nearby
- Verify Arduino code is properly uploaded
- Restart both devices if needed

### Fingerprint Issues
- Ensure fingerprint is enrolled on device
- Clean fingerprint sensor
- Try alternative finger or re-enroll

### Sensor Data Issues
- Check Arduino sensor connections
- Verify sensor calibration
- Restart Arduino if needed

## Development

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── providers/
│   └── bag_state_provider.dart  # State management
├── services/
│   ├── bluetooth_service.dart   # Bluetooth communication
│   ├── auth_service.dart        # Fingerprint authentication
│   └── bag_controller_service.dart # Main controller
├── screens/
│   ├── home_screen.dart         # Main interface
│   └── device_scan_screen.dart  # Device discovery
└── widgets/
    ├── connection_widget.dart   # Connection status
    ├── sensor_widget.dart       # Sensor displays
    ├── control_widget.dart      # Control buttons
    └── admin_widget.dart        # Admin panel
```

### Key Dependencies
- `flutter_blue_plus`: Bluetooth LE communication
- `local_auth`: Fingerprint authentication
- `provider`: State management
- `fl_chart`: Data visualization
- `permission_handler`: Permission management

## Security Features

- **Fingerprint Authentication**: Required for all control operations
- **Encrypted Communication**: Bluetooth data encryption
- **Permission-based Access**: Granular permission control
- **Secure Storage**: Encrypted local storage for settings

## Future Enhancements

- Cloud synchronization
- Multiple bag support
- Advanced analytics
- Weather integration
- Social features
- Voice commands

## Support

For technical support or feature requests, please contact the development team.

## License

This project is licensed under the MIT License - see the LICENSE file for details.