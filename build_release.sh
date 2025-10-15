#!/bin/bash

# Script to build a secure release version of the weather app

echo "Building secure release version of the weather app..."

# 1. Clean the project
echo "Cleaning the project..."
flutter clean
flutter pub get

# 2. Build the APK with code obfuscation and split debug info
echo "Building APK with obfuscation..."
flutter build apk --release --obfuscate --split-debug-info=./debug-info

# 3. Build the iOS app bundle
echo "Building iOS app bundle..."
flutter build ios --release --obfuscate --split-debug-info=./debug-info

echo "Release builds completed!"
echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
echo "iOS app location: build/ios/iphoneos/Runner.app"

echo "IMPORTANT: For production deployment:"
echo "1. The API key is securely stored in native platform storage"
echo "2. The app uses platform channels to retrieve the key at runtime"
echo "3. Code is obfuscated to prevent reverse engineering"
echo "4. Debug information is split and should be stored securely"