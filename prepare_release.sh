#!/bin/bash

# Prepare Release Build for QA Testing

echo "========================================="
echo "Secure Weather App - Release Build Script"
echo "========================================="

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "Error: pubspec.yaml not found. Please run this script from the project root directory."
    exit 1
fi

echo "1. Cleaning project..."
flutter clean

echo "2. Getting dependencies..."
flutter pub get

echo "3. Building release APK with security features..."
flutter build apk --release --obfuscate --split-debug-info=./debug-info

if [ $? -eq 0 ]; then
    echo "✅ APK build successful!"
    echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
else
    echo "❌ APK build failed!"
    exit 1
fi

echo "4. Building iOS app bundle with security features..."
flutter build ios --release --obfuscate --split-debug-info=./debug-info

if [ $? -eq 0 ]; then
    echo "✅ iOS build successful!"
    echo "iOS app location: build/ios/iphoneos/Runner.app"
else
    echo "❌ iOS build failed!"
    exit 1
fi

echo ""
echo "========================================="
echo "Build Summary:"
echo "========================================="
echo "✓ Release APK: build/app/outputs/flutter-apk/app-release.apk"
echo "✓ iOS App: build/ios/iphoneos/Runner.app"
echo "✓ Debug info: ./debug-info (keep secure!)"
echo ""
echo "========================================="
echo "Security Features Included:"
echo "========================================="
echo "✓ API key stored in secure platform storage"
echo "✓ Code obfuscation enabled"
echo "✓ Network traffic encryption (HTTPS)"
echo "✓ Root/jailbreak detection"
echo "✓ Debugger detection"
echo "✓ App integrity verification"
echo "✓ Secure HTTP headers"
echo ""
echo "========================================="
echo "Next Steps:"
echo "========================================="
echo "1. Test the APK on Android devices"
echo "2. Test the iOS app on iOS devices"
echo "3. Verify security features using the guidelines in QA_INSTRUCTIONS.md"
echo "4. Report any issues found"
echo ""
echo "For detailed testing instructions, see: QA_INSTRUCTIONS.md"
echo "For security implementation details, see: SECURITY.md"
echo "========================================="