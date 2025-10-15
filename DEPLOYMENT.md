# Production Deployment Guide

## Secure API Key Setup

For production deployment, you need to securely store the API key in the native platform storage.

## Android Setup

### 1. Pre-populate Secure Storage (Recommended for Production)

Before building the release APK, you can pre-populate the encrypted storage with your API key:

```kotlin
// In your MainActivity.kt, modify the storeDefaultApiKeyIfNeeded() method:
private fun storeDefaultApiKeyIfNeeded() {
    try {
        val currentApiKey = encryptedPrefs?.getString(API_KEY_STORAGE_KEY, "")
        if (currentApiKey.isNullOrEmpty()) {
            // Store your PRODUCTION API key here
            storeApiKeyInSecureStorage("YOUR_PRODUCTION_API_KEY_HERE")
        }
    } catch (e: Exception) {
        e.printStackTrace()
    }
}
```

### 2. Alternative: Server-side Initialization

For maximum security, you can retrieve the API key from your own secure server after the app is installed:

```kotlin
// In your MainActivity.kt, add a method to fetch the key from your server:
private fun fetchApiKeyFromSecureServer() {
    // Implement secure HTTP request to your server
    // Store the retrieved key in encrypted storage
}
```

## iOS Setup

### 1. Pre-populate Keychain (Recommended for Production)

```swift
// In your AppDelegate.swift, modify the storeDefaultApiKeyIfNeeded() method:
private func storeDefaultApiKeyIfNeeded() {
    let currentApiKey = getApiKeyFromKeychain()
    if currentApiKey == nil || currentApiKey!.isEmpty {
        // Store your PRODUCTION API key here
        storeApiKeyInKeychain("YOUR_PRODUCTION_API_KEY_HERE")
    }
}
```

## Building for Release

### 1. Build with Obfuscation

```bash
# Build APK with obfuscation
flutter build apk --release --obfuscate --split-debug-info=./debug-info

# Build iOS app with obfuscation
flutter build ios --release --obfuscate --split-debug-info=./debug-info
```

### 2. Secure Debug Information

The `--split-debug-info` flag creates debug symbol files that should be:
- Stored securely (not included in the app distribution)
- Used only for crash analysis
- Protected with access controls

## Testing the Release Build

### 1. Install on Device

```bash
# Install APK on connected device
flutter install

# Or use adb
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 2. Verify Security

- Use tools like `apktool` to verify the API key is not in the source
- Check network traffic to ensure HTTPS is used
- Verify that the app detects rooted/jailbroken devices

## Security Verification Checklist

- [ ] API key is not visible in decompiled source code
- [ ] API key is stored in secure platform storage (Android Keystore / iOS Keychain)
- [ ] Network traffic is encrypted (HTTPS)
- [ ] Code is obfuscated
- [ ] App detects rooted/jailbroken devices
- [ ] Debug information is separated from the app
- [ ] No sensitive information in error messages
- [ ] All platform channels are properly secured

## Post-Deployment Security

1. Monitor API usage for unusual patterns
2. Implement certificate pinning for additional security
3. Regularly rotate API keys
4. Use analytics to detect potential security issues
5. Keep dependencies updated

## Troubleshooting

### Common Issues

1. **API Key Not Found**: Ensure the key is properly stored in platform-specific secure storage
2. **Platform Channel Errors**: Verify the method channel names match between Flutter and native code
3. **Encryption Errors**: Check that the device meets minimum security requirements (Android API 23+)

### Debugging Release Builds

For debugging release builds, you can temporarily enable logging:

```dart
// In your Dart code, add conditional logging:
if (kDebugMode) {
  print('Debug info: $data');
}
```

Never leave sensitive logging in production code.