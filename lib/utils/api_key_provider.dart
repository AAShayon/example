import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/services.dart' show MethodChannel;

class ApiKeyProvider {
  static const MethodChannel _channel = MethodChannel('secure_weather_channel');
  
  // For web, we can use environment variables
  static const String _webApiKey = String.fromEnvironment('WEATHER_API_KEY', defaultValue: '');
  
  static Future<String> getApiKey() async {
    // For web, use environment variables
    if (kIsWeb) {
      return _webApiKey;
    }
    
    // For mobile platforms, use platform channels to get the key from secure native storage
    try {
      final String apiKey = await _channel.invokeMethod('getApiKey');
      if (kDebugMode) {
        print('Retrieved API key from platform channel: "$apiKey" (length: ${apiKey.length})');
      }
      
      // If we got an empty key, handle appropriately
      if (apiKey.isEmpty) {
        // In debug mode, we can use a fallback key for testing
        // In production, you should handle this appropriately
        if (kDebugMode) {
          print('Using debug API key as fallback');
          return '162d984ea8c348c1b84113333242604';
        } else {
          throw Exception('API key not found in secure storage');
        }
      }
      return apiKey;
    } catch (e) {
      // In debug mode, we can use a fallback key for testing
      // In production, you should handle this error appropriately
      if (kDebugMode) {
        print('Using debug API key due to error: $e');
        return '162d984ea8c348c1b84113333242604';
      }
      
      // In production, rethrow the error
      throw Exception('Failed to retrieve API key: $e');
    }
  }
  
  // Method to store API key (for demonstration purposes)
  static Future<void> storeApiKey(String apiKey) async {
    if (kIsWeb) {
      // On web, we can't securely store keys, so this is just for demonstration
      return;
    }
    
    try {
      if (kDebugMode) {
        print('Storing API key through platform channel: "$apiKey"');
      }
      await _channel.invokeMethod('storeApiKey', {'apiKey': apiKey});
      if (kDebugMode) {
        print('Successfully stored API key through platform channel');
      }
    } catch (e) {
      // Handle error appropriately
      if (kDebugMode) {
        print('Failed to store API key: $e');
      }
      rethrow;
    }
  }
}