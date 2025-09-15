import 'dart:math';
import 'package:dio/dio.dart';
import 'package:example/constants/api_constants.dart';
import 'package:example/services/security_service.dart';
import 'package:example/services/app_security_manager.dart';

class SecureHttpClient {
  static final SecureHttpClient _instance = SecureHttpClient._internal();
  factory SecureHttpClient() => _instance;
  SecureHttpClient._internal();

  late Dio _dio;
  final SecurityService _securityService = SecurityService();
  final AppSecurityManager _appSecurityManager = AppSecurityManager();

  Future<void> initialize() async {
    _dio = Dio();
    
    // Add interceptors for security
    _dio.interceptors.add(SecurityInterceptor(_appSecurityManager));
    _dio.interceptors.add(LoggingInterceptor());
    
    // Secure the API key
    await _securityService.secureApiKey(ApiConstants.apiKey);
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    // Check if app has been tampered with
    if (_appSecurityManager.isAppTampered()) {
      throw Exception('Security violation detected');
    }

    // Verify app integrity
    if (!await _appSecurityManager.verifyAppIntegrity()) {
      throw Exception('App integrity check failed');
    }

    // Add security layers to request
    final secureParams = await _addSecurityLayers(queryParameters ?? {});
    
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}$endpoint',
        queryParameters: secureParams,
      );
      
      // Decrypt response if needed
      return await _decryptResponse(response);
    } on DioException catch (e) {
      // Handle error securely
      throw _handleSecureError(e);
    }
  }

  Future<Map<String, dynamic>> _addSecurityLayers(Map<String, dynamic> params) async {
    // Add API key from security service
    params['key'] = await _securityService.getApiKey();
    
    // Add timestamp to prevent replay attacks
    params['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Add random parameter to prevent caching
    params['nonce'] = Random().nextInt(1000000).toString();
    
    // Add signature for request validation
    final signature = await _generateSignature(params);
    params['signature'] = signature;
    
    return params;
  }

  Future<String> _generateSignature(Map<String, dynamic> params) async {
    // Sort parameters for consistent signature
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
    
    // Create string to sign
    final paramString = sortedParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    // Generate signature
    final signature = await _securityService.encryptData(paramString);
    return signature;
  }

  Future<Response> _decryptResponse(Response response) async {
    // In a real implementation, you might decrypt sensitive parts of the response
    // For this example, we'll just return the response as is
    return response;
  }

  DioException _handleSecureError(DioException error) {
    // Log error securely (in production, send to secure logging service)
    // Don't expose sensitive information in error messages
    return DioException(
      error: error.error,
      message: 'A secure error occurred',
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
    );
  }
}

class SecurityInterceptor extends Interceptor {
  final AppSecurityManager _appSecurityManager;
  
  SecurityInterceptor(this._appSecurityManager);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add security headers from app security manager
    final securityHeaders = _appSecurityManager.getSecurityHeaders();
    options.headers.addAll(securityHeaders);
    
    // Add a random header to prevent fingerprinting
    options.headers['X-Random-Identifier'] = Random().nextInt(1000000).toString();
    
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Add security headers to response
    final securityHeaders = _appSecurityManager.getSecurityHeaders();
    securityHeaders.forEach((key, value) {
      response.headers.set(key, value);
    });
    
    super.onResponse(response, handler);
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // In production, log to a secure service, not console
    // print('SECURE REQUEST: ${options.method} ${options.uri}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // In production, log to a secure service, not console
    // print('SECURE RESPONSE: ${response.statusCode} ${response.realUri}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // In production, log errors securely
    // print('SECURE ERROR: ${err.message}');
    super.onError(err, handler);
  }
}