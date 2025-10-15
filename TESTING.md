# Security Testing Guide

## How to Test the Secure Implementation

### 1. Debug Mode Testing

In debug mode, the app should:
- Display weather data when you enter a location
- Use the fallback API key for testing
- Show some security warnings in the console

To test in debug mode:
```bash
flutter run
```

### 2. Release Mode Testing

In release mode, the app should:
- Retrieve the API key from secure platform storage
- Have all security checks enabled
- Be resistant to reverse engineering

To build and test in release mode:
```bash
# Build release APK
flutter build apk --release

# Install on device
flutter install

# Or use adb
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Security Verification Tests

### Test 1: Static Analysis Resistance

1. Build the release APK:
   ```bash
   flutter build apk --release --obfuscate
   ```

2. Try to extract the API key using common tools:
   ```bash
   # Extract APK
   apktool d build/app/outputs/flutter-apk/app-release.apk
   
   # Search for API key
   grep -r "162d984ea8c348c1b84113333242604" .
   ```

   Expected result: No matches found

### Test 2: Runtime Memory Protection

1. Run the app on a rooted device or emulator
2. Use a memory dumping tool to inspect the app's memory
3. Search for the API key in memory

Expected result: API key should be obfuscated or not visible

### Test 3: Network Traffic Security

1. Install a proxy tool like Burp Suite or mitmproxy
2. Configure your device to route traffic through the proxy
3. Run the app and monitor network requests

Expected result:
- All traffic should be HTTPS
- API key should not be visible in URLs or headers
- Requests should include security headers

### Test 4: Platform Storage Security

#### Android:
1. Use adb to explore the app's data directory:
   ```bash
   adb shell
   run-as com.example.example
   ls shared_prefs/
   ```

2. Try to read the encrypted preferences:
   ```bash
   cat shared_prefs/secure_weather_prefs.xml
   ```

Expected result: Data should be encrypted and not readable

#### iOS:
1. Use a jailbroken device with access to the keychain
2. Try to extract keychain data

Expected result: Keychain data should be encrypted

## Reverse Engineering Tests

### Test 1: APK Decompilation

1. Use jadx to decompile the APK:
   ```bash
   jadx -d output_dir app-release.apk
   ```

2. Search for sensitive information in the decompiled code

Expected result: No API keys, passwords, or other sensitive data should be visible

### Test 2: Code Obfuscation Verification

1. Check if method and class names are obfuscated
2. Verify that the code is difficult to understand

Expected result: Code should be obfuscated and hard to follow

## Security Feature Verification

### Test 1: Root/Jailbreak Detection

1. Run the app on a rooted Android device or jailbroken iOS device
2. Observe the app's behavior

Expected result: App should detect the rooted/jailbroken state and respond appropriately

### Test 2: Debugger Detection

1. Attach a debugger to the running app
2. Observe the app's behavior

Expected result: App should detect the debugger and respond appropriately

### Test 3: App Integrity Check

1. Modify the app's code or resources
2. Run the modified app

Expected result: App should detect the modification and respond appropriately

## Performance Testing

### Test 1: Security Overhead

1. Measure app startup time with security enabled
2. Compare with a version that has security disabled

Expected result: Security should add minimal overhead

### Test 2: Battery Usage

1. Monitor battery usage with security features active
2. Ensure security features don't drain battery excessively

Expected result: Battery usage should be reasonable

## Reporting Security Issues

If you find any security vulnerabilities:

1. Do not publicly disclose the issue
2. Contact the development team directly
3. Provide detailed information about the vulnerability
4. Include steps to reproduce the issue
5. Suggest possible fixes

## Security Best Practices for QA

1. Always test on both Android and iOS
2. Test on different device types and OS versions
3. Test both debug and release builds
4. Verify that security features work in offline mode
5. Test error handling and edge cases
6. Document all test results
7. Regularly update testing procedures

This guide should help QA engineers thoroughly test the security features of the app.