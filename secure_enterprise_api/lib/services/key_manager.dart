import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import '../utils/constants.dart';

class KeyManager {
  static final KeyManager _instance = KeyManager._internal();
  factory KeyManager() => _instance;
  KeyManager._internal();

  static const MethodChannel _channel = MethodChannel('secure_enterprise_api');
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Store API key securely
  Future<void> storeApiKey(String apiKey) async {
    try {
      // Store in Flutter secure storage
      await _secureStorage.write(key: ApiConstants.secureStorageKey, value: apiKey);
      
      // Also store salt for validation
      final salt = _generateSalt();
      await _secureStorage.write(key: ApiConstants.secureStorageSalt, value: salt);
      
      // Hash the key for validation
      final hashedKey = _hashWithSalt(apiKey, salt);
      await _secureStorage.write(key: '${ApiConstants.secureStorageKey}_hash', value: hashedKey);
    } catch (e) {
      // Rethrow in production
      rethrow;
    }
  }

  /// Retrieve API key securely
  Future<String?> getApiKey() async {
    try {
      // Try to get from secure storage first
      final storedKey = await _secureStorage.read(key: ApiConstants.secureStorageKey);
      if (storedKey != null && storedKey.isNotEmpty) {
        // Validate the key
        if (await _validateApiKey(storedKey)) {
          return storedKey;
        }
      }
      
      // Try to get from platform channel
      try {
        final platformKey = await _channel.invokeMethod<String>('getApiKey');
        if (platformKey != null && platformKey.isNotEmpty) {
          // Store it for future use
          await storeApiKey(platformKey);
          return platformKey;
        }
      } catch (e) {
        // Platform channel not available
      }
      
      // Return default key if set
      return ApiConstants.apiKey.isNotEmpty ? ApiConstants.apiKey : null;
    } catch (e) {
      return null;
    }
  }

  /// Clear stored API key
  Future<void> clearApiKey() async {
    try {
      await _secureStorage.delete(key: ApiConstants.secureStorageKey);
      await _secureStorage.delete(key: ApiConstants.secureStorageSalt);
      await _secureStorage.delete(key: '${ApiConstants.secureStorageKey}_hash');
    } catch (e) {
      // Ignore errors
    }
  }

  /// Validate API key
  Future<bool> _validateApiKey(String apiKey) async {
    try {
      final salt = await _secureStorage.read(key: ApiConstants.secureStorageSalt);
      final storedHash = await _secureStorage.read(key: '${ApiConstants.secureStorageKey}_hash');
      
      if (salt == null || storedHash == null) {
        return false;
      }
      
      final inputHash = _hashWithSalt(apiKey, salt);
      return inputHash == storedHash;
    } catch (e) {
      return false;
    }
  }

  /// Generate random salt
  String _generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// Create hash with salt
  String _hashWithSalt(String input, String salt) {
    final bytes = utf8.encode(input + salt);
    final hash = sha256.convert(bytes);
    return base64Url.encode(hash.bytes);
  }
}