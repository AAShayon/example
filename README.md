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
   - Keys are stored securely using flutter_secure_storage
   - Keys are hashed and salted for additional protection

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
│   └── api_constants.dart          # API configuration
├── screens/
│   ├── splash_screen.dart          # Initial splash screen with security checks
│   └── home_page.dart              # Main weather forecast interface
├── services/
│   ├── app_security_manager.dart   # Device and app security checks
│   ├── secure_http_client.dart     # Secure HTTP communication
│   ├── security_service.dart       # Data encryption and security utilities
│   └── weather_service.dart        # Weather data management
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
3. Add your WeatherAPI key to `lib/constants/api_constants.dart`
4. Run the app with `flutter run`

## Security Best Practices Implemented

1. **Never store secrets in plain text**
2. **Use secure storage for sensitive information**
3. **Implement multiple layers of security**
4. **Obfuscate sensitive data in memory**
5. **Prevent debugging and tampering**
6. **Sanitize error messages**
7. **Add security headers to all requests**
8. **Implement integrity checks**
9. **Use secure random number generation**
10. **Encrypt data in transit**

## API Used

This app uses the [WeatherAPI](https://www.weatherapi.com/) for weather forecasting data.

## Contributing

Contributions are welcome! Please read the contributing guidelines before submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.