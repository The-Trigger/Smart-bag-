#!/bin/bash

# Smart Bag Controller - Build Script
# This script automates the build process for the Flutter app

echo "🚀 Smart Bag Controller - Build Script"
echo "======================================"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | grep -o "Flutter [0-9]\+\.[0-9]\+\.[0-9]\+" | cut -d' ' -f2)
echo "📱 Flutter version: $FLUTTER_VERSION"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Please run this script from the smart_bag_controller directory"
    exit 1
fi

echo ""
echo "🔧 Setting up the project..."

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Check for any issues
echo "🔍 Checking for issues..."
flutter doctor

echo ""
echo "🏗️ Building the app..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies again after clean
flutter pub get

# Build for Android
echo "📱 Building Android APK..."
flutter build apk --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build completed successfully!"
    echo ""
    echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📋 Installation instructions:"
    echo "1. Enable 'Install from unknown sources' on your Android device"
    echo "2. Transfer the APK to your device"
    echo "3. Install the APK"
    echo "4. Grant necessary permissions when prompted"
    echo ""
    echo "🔧 Required permissions:"
    echo "- Bluetooth"
    echo "- Location (required for Bluetooth scanning)"
    echo "- Biometric (fingerprint)"
    echo "- SMS (for admin features)"
    echo ""
    echo "📖 For more information, see README.md"
else
    echo ""
    echo "❌ Build failed. Please check the error messages above."
    exit 1
fi

echo ""
echo "🎉 Build script completed!"