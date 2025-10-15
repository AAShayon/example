import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:secure_enterprise_api/utils/constants.dart';


class AuthInterceptor extends Interceptor {
  static const MethodChannel _channel = MethodChannel('secure_enterprise_api');
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Try to get API key from secure storage first
      String? apiKey = await _secureStorage.read(key: ApiConstants.secureStorageKey);
      
      // If not found in secure storage, try to get from platform channel
      if (apiKey == null || apiKey.isEmpty) {
        try {
          apiKey = await _channel.invokeMethod<String>('getApiKey');
        } catch (e) {
          // Platform channel not available, use fallback
          apiKey = ApiConstants.apiKey;
        }
      }
      
      // Add API key to request if available
      if (apiKey != null && apiKey.isNotEmpty) {
        options.queryParameters['api_key'] = apiKey;
      }
      
      // Add timestamp to prevent replay attacks
      options.queryParameters['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Add nonce to prevent caching
      options.queryParameters['nonce'] = DateTime.now().microsecondsSinceEpoch.toString();
      
    } catch (e) {
      // Don't fail the request if we can't add auth
      // In production, you might want to handle this differently
    }
    
    super.onRequest(options, handler);
  }
}