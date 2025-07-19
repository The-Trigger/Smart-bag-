#!/bin/bash

# Smart Bag Control App Build Script
# This script builds the Flutter app for Android export

echo "🚀 Building Smart Bag Control App..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check Flutter version
echo "📋 Flutter version:"
flutter --version

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Check for issues
echo "🔍 Checking for issues..."
flutter analyze

# Build APK for release
echo "🔨 Building APK for release..."
flutter build apk --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"
    echo "📏 APK size:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk
    
    echo ""
    echo "🎉 Smart Bag Control App is ready for installation!"
    echo ""
    echo "📋 Installation instructions:"
    echo "1. Transfer the APK to your Android device"
    echo "2. Enable 'Install from unknown sources' in device settings"
    echo "3. Install the APK file"
    echo "4. Grant necessary permissions when prompted"
    echo ""
    echo "🔧 Requirements:"
    echo "- Android 11 or higher"
    echo "- Bluetooth 4.0+ support"
    echo "- Fingerprint sensor (optional)"
    echo "- Smart bag with Arduino Mega"
else
    echo "❌ Build failed!"
    exit 1
fi