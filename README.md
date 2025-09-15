# Secure Weather Forecast App

A Flutter weather forecasting application with multiple security layers to prevent hacking, reverse engineering, and unauthorized access to API responses.

## Features

- **Secure API Communication**: All API requests are secured with multiple layers of encryption and authentication
- **Tamper Detection**: The app detects if it has been tampered with or is running on a rooted/jailbroken device
- **Data Encryption**: Sensitive data is encrypted both in transit and at rest
- **Secure Storage**: API keys and sensitive information are stored securely using flutter_secure_storage
- **Obfuscation**: Code and data are obfuscated to prevent reverse engineering
- **Security Headers**: All HTTP requests include security headers to prevent common web vulnerabilities
- **Integrity Checks**: The app performs integrity checks to ensure it hasn't been modified

## Security Layers

1. **API Key Protection**:
   - API keys are never hardcoded in plain text
   - Keys are stored securely using platform-specific secure storage (Android Keystore, iOS Keychain)
   - Keys are retrieved through platform channels for maximum security
   - In development, a fallback key is used (NOT recommended for production)

2. **Request Security**:
   - All requests include timestamp and nonce to prevent replay attacks
   - Requests are signed with a cryptographic signature
   - Security headers are added to all requests

3. **Response Security**:
   - Responses are encrypted before being sent to the UI
   - Sensitive data is obfuscated in memory
   - Error messages are sanitized to prevent information leakage

4. **Device Security**:
   - Root/Jailbreak detection
   - Debugger detection
   - App integrity verification

5. **Data Security**:
   - Encryption of sensitive data at rest
   - Secure random number generation
   - Data obfuscation techniques

## Architecture

The app follows a layered architecture with clear separation of concerns:

```
lib/
├── constants/
│   └── api_constants.dart          # API configuration (without keys)
├── screens/
│   ├── splash_screen.dart          # Initial splash screen with security checks
│   └── home_page.dart              # Main weather forecast interface
├── services/
│   ├── app_security_manager.dart   # Device and app security checks
│   ├── secure_http_client.dart     # Secure HTTP communication
│   ├── security_service.dart       # Data encryption and security utilities
│   └── weather_service.dart        # Weather data management
├── utils/
│   └── api_key_provider.dart       # Secure API key provider using platform channels
└── main.dart                       # App entry point
```

## Dependencies

- `dio`: HTTP client with interceptors
- `flutter_secure_storage`: Secure storage for sensitive data
- `crypto`: Cryptographic functions
- `provider`: State management

## Setup

1. Clone the repository
2. Run `flutter pub get`
3. For development, the app will use a fallback API key (NOT recommended for production)
4. For production, the API key is securely stored in native platform storage and retrieved through platform channels

## Production Security Implementation

### Android Implementation

The Android implementation uses EncryptedSharedPreferences with Android Keystore to securely store the API key:

1. The API key is stored in EncryptedSharedPreferences, which automatically encrypts both keys and values
2. Encryption is done using a master key stored in Android Keystore
3. The master key is generated with AES256-GCM encryption

### iOS Implementation

The iOS implementation uses Keychain Services to securely store the API key:

1. The API key is stored in the iOS Keychain, which is hardware-encrypted
2. Access to the keychain is protected by the system
3. Keys are stored with appropriate accessibility attributes

### Platform Channel Communication

The Flutter app communicates with the native platforms through method channels:

1. `getApiKey`: Retrieves the API key from secure native storage
2. `storeApiKey`: Stores the API key in secure native storage (for initial setup)

## Security Best Practices Implemented

1. **Never store secrets in plain text** - All sensitive data is encrypted at rest
2. **Use platform-specific secure storage** - Android Keystore and iOS Keychain
3. **Implement multiple layers of security** - Defense in depth approach
4. **Obfuscate sensitive data in memory** - Data is obfuscated when not in use
5. **Prevent debugging and tampering** - Debugger and tamper detection
6. **Sanitize error messages** - No sensitive information in error messages
7. **Add security headers to all requests** - Protection against common web vulnerabilities
8. **Implement integrity checks** - Verify app hasn't been modified
9. **Use secure random number generation** - Cryptographically secure random numbers
10. **Encrypt data in transit** - All network communication is secured

## API Used

This app uses the [WeatherAPI](https://www.weatherapi.com/) for weather forecasting data.

## Contributing

Contributions are welcome! Please read the contributing guidelines before submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.