# Secure Enterprise API

A secure Flutter package for enterprise applications that protects sensitive endpoints and API keys from reverse engineering and unauthorized access.

## Features

- 🔐 **Secure Key Storage**: Stores API keys in platform-native secure storage (Android Keystore, iOS Keychain)
- 🛡️ **Network Security**: Implements HTTPS, certificate pinning, and security headers
- 🕵️ **Anti-Reverse Engineering**: Obfuscates endpoints and prevents API discovery
- 🔒 **Request Signing**: Adds request signatures to prevent tampering
- 📱 **Cross-Platform**: Works on both Android and iOS
- 🚀 **Easy Integration**: Simple API for making secure HTTP requests

## Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  secure_enterprise_api:
    git:
      url: https://your-git-repo.com/secure_enterprise_api.git
      ref: main
```

Or if you're publishing to pub.dev:

```yaml
dependencies:
  secure_enterprise_api: ^1.0.0
```

## Usage

### 1. Initialize the Client

```dart
import 'package:secure_enterprise_api/secure_enterprise_api.dart';

void main() async {
  // Initialize the secure API client
  await SecureApiClient().initialize(
    baseUrl: 'https://your-secure-api.com/api/',
    connectTimeout: 30000,
    receiveTimeout: 30000,
  );
  
  runApp(MyApp());
}
```

### 2. Make Secure API Calls

```dart
import 'package:secure_enterprise_api/secure_enterprise_api.dart';

class WeatherService {
  final _apiClient = SecureApiClient();
  
  Future<ApiResponse<WeatherData>> getWeather(String location) async {
    try {
      final response = await _apiClient.get<WeatherData>(
        'weather',
        queryParameters: {'q': location},
      );
      
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to fetch weather data');
    }
  }
}
```

### 3. Secure Key Management

```dart
import 'package:secure_enterprise_api/secure_enterprise_api.dart';

class ApiKeyManager {
  final _keyManager = KeyManager();
  
  // Store API key securely
  Future<void> storeApiKey(String apiKey) async {
    await _keyManager.storeApiKey(apiKey);
  }
  
  // Retrieve API key securely
  Future<String?> getApiKey() async {
    return await _keyManager.getApiKey();
  }
}
```

## Security Features

### 1. Platform-Native Key Storage
- **Android**: Uses EncryptedSharedPreferences with Android Keystore
- **iOS**: Uses Keychain Services with hardware encryption

### 2. Network Security
- Automatic HTTPS enforcement
- Security headers to prevent common attacks
- Request signing for integrity verification
- Certificate pinning support

### 3. Anti-Reverse Engineering
- Endpoints are not hardcoded in plain text
- API keys are stored in secure native storage
- Code obfuscation makes discovery difficult
- Random headers prevent fingerprinting

### 4. Request Security
- Timestamp-based replay attack prevention
- Nonce-based caching prevention
- Request signature verification
- Automatic security header injection

## Configuration

### Android Setup

Add these permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS Setup

No additional setup required for iOS.

## Best Practices

1. **Use Backend Proxy**: Route all API calls through your own backend server
2. **Implement Certificate Pinning**: Add SSL certificate pinning for additional security
3. **Use Temporary Tokens**: Implement token-based authentication instead of permanent keys
4. **Regular Key Rotation**: Rotate API keys regularly
5. **Monitor Usage**: Implement logging and monitoring for suspicious activity

## Enterprise Deployment

For enterprise use, deploy this package as a private package:

1. Host on a private Git repository
2. Use environment-specific API keys
3. Implement role-based access control
4. Add audit logging
5. Regular security assessments

## Contributing

This is a private enterprise package. For contributions, please contact your security team.

## License

This package is proprietary and confidential. Unauthorized use is prohibited.