import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:example/utils/api_key_provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _apiKeyStorageKey = 'weather_api_key';

  // Generate a random salt
  String _generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  // Create a hash with salt
  String _hashWithSalt(String input, String salt) {
    final bytes = utf8.encode(input + salt);
    final hash = sha256.convert(bytes);
    return base64Url.encode(hash.bytes);
  }

  // Generate a key for encryption
  String _generateKey(String input) {
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);
    return base64Url.encode(hash.bytes);
  }

  // Simple XOR encryption for demonstration
  String _simpleEncrypt(String plainText, String key) {
    final plainBytes = utf8.encode(plainText);
    final keyBytes = utf8.encode(key);
    final encryptedBytes = <int>[];

    for (int i = 0; i < plainBytes.length; i++) {
      encryptedBytes.add(plainBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64Url.encode(encryptedBytes);
  }

  // Simple XOR decryption for demonstration
  String _simpleDecrypt(String encryptedText, String key) {
    final encryptedBytes = base64Url.decode(encryptedText);
    final keyBytes = utf8.encode(key);
    final decryptedBytes = <int>[];

    for (int i = 0; i < encryptedBytes.length; i++) {
      decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return utf8.decode(decryptedBytes);
  }

  // Secure the API key
  Future<void> secureApiKey() async {
    try {
      // Get the API key from the secure provider
      final apiKey = await ApiKeyProvider.getApiKey();
      
      if (kDebugMode) {
        print('Securing API key: $apiKey');
      }
      
      // Store the API key directly without obfuscation to avoid corruption
      await _secureStorage.write(key: _apiKeyStorageKey, value: apiKey);
      
      // Also store salt for hashing
      final salt = _generateSalt();
      final hashedKey = _hashWithSalt(apiKey, salt);
      await _secureStorage.write(key: 'api_salt', value: salt);
      await _secureStorage.write(key: 'api_hash', value: hashedKey);
    } catch (e) {
      // In debug mode, we'll allow fallback
      if (kDebugMode) {
        print('Warning: Failed to secure API key: $e');
      } else {
        rethrow;
      }
    }
  }

  // Obfuscate string for basic protection
  String _obfuscateString(String input) {
    // Simple obfuscation - in a real app, use more sophisticated methods
    // Using a fixed offset instead of random to make it deterministic
    if (kDebugMode) {
      print('Obfuscating input: $input');
    }
    final values = List<int>.generate(input.length, (i) => input.codeUnitAt(i) + (i % 10));
    final obfuscated = base64Url.encode(values);
    if (kDebugMode) {
      print('Obfuscated result: $obfuscated');
    }
    return obfuscated;
  }

  // Deobfuscate string
  String _deobfuscateString(String input) {
    // This is a simplified implementation for demonstration
    // In a real app, you would implement proper deobfuscation
    try {
      if (kDebugMode) {
        print('Deobfuscating input: $input');
      }
      final values = base64Url.decode(input);
      final result = StringBuffer();
      for (int i = 0; i < values.length; i++) {
        result.writeCharCode(values[i] - (i % 10));
      }
      final deobfuscated = result.toString();
      if (kDebugMode) {
        print('Deobfuscated result: $deobfuscated');
      }
      return deobfuscated;
    } catch (e) {
      // In case of error, return a dummy key to prevent exposing the real one
      if (kDebugMode) {
        print('Error during deobfuscation: $e');
      }
      return 'invalid_key';
    }
  }

  // Validate API key
  Future<bool> validateApiKey(String apiKey) async {
    final salt = await _secureStorage.read(key: 'api_salt');
    final storedHash = await _secureStorage.read(key: 'api_hash');
    
    if (salt == null || storedHash == null) {
      return false;
    }

    final inputHash = _hashWithSalt(apiKey, salt);
    return inputHash == storedHash;
  }

  // Encrypt data
  Future<String> encryptData(String data) async {
    final key = _generateKey(await _secureStorage.read(key: 'api_salt') ?? 'default');
    return _simpleEncrypt(data, key);
  }

  // Decrypt data
  Future<String> decryptData(String encryptedData) async {
    final key = _generateKey(await _secureStorage.read(key: 'api_salt') ?? 'default');
    return _simpleDecrypt(encryptedData, key);
  }

  // Get the API key
  Future<String> getApiKey() async {
    try {
      // First, try to retrieve the key from secure storage
      final storedKey = await _secureStorage.read(key: _apiKeyStorageKey);
      if (storedKey != null && storedKey.isNotEmpty) {
        if (kDebugMode) {
          print('Retrieved API key from secure storage: $storedKey');
        }
        // Validate the key
        if (await validateApiKey(storedKey)) {
          return storedKey;
        } else {
          if (kDebugMode) {
            print('WARNING: Invalid key from secure storage, falling back to provider');
          }
        }
      }
      
      // Fallback to the provider
      final providerKey = await ApiKeyProvider.getApiKey();
      if (kDebugMode) {
        print('Retrieved API key from provider: $providerKey');
      }
      return providerKey;
    } catch (e) {
      // In debug mode, we'll allow fallback
      if (kDebugMode) {
        print('Warning: Failed to retrieve API key from secure storage: $e');
        return await ApiKeyProvider.getApiKey();
      } else {
        rethrow;
      }
    }
  }

  // Clear all secure data
  Future<void> clearSecureData() async {
    await _secureStorage.deleteAll();
  }
}
