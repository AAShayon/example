import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:example/constants/api_constants.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

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
  Future<void> secureApiKey(String apiKey) async {
    final salt = _generateSalt();
    final hashedKey = _hashWithSalt(apiKey, salt);
    await _secureStorage.write(key: 'api_salt', value: salt);
    await _secureStorage.write(key: 'api_hash', value: hashedKey);
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

  // Get the API key (in a real app, you would never expose the API key directly)
  Future<String> getApiKey() async {
    // In a real implementation, you would use more sophisticated methods
    // to protect the API key, such as using platform channels or secure enclaves
    return ApiConstants.apiKey;
  }

  // Clear all secure data
  Future<void> clearSecureData() async {
    await _secureStorage.deleteAll();
  }
}