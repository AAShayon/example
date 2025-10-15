import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../utils/constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/security_interceptor.dart';

class SecureApiClient {
  static final SecureApiClient _instance = SecureApiClient._internal();
  factory SecureApiClient() => _instance;
  SecureApiClient._internal();

  late Dio _dio;
  final Logger _logger = Logger();
  bool _isInitialized = false;

  /// Initialize the API client with base URL and optional configuration
  Future<void> initialize({
    required String baseUrl,
    Map<String, dynamic>? defaultHeaders,
    int connectTimeout = 30000,
    int receiveTimeout = 30000,
  }) async {
    if (_isInitialized) return;

    _dio = Dio();
    
    // Configure timeouts
    _dio.options.connectTimeout = Duration(milliseconds: connectTimeout);
    _dio.options.receiveTimeout = Duration(milliseconds: receiveTimeout);
    
    // Set base URL
    _dio.options.baseUrl = baseUrl;
    
    // Add interceptors
    _dio.interceptors.add(SecurityInterceptor());
    _dio.interceptors.add(AuthInterceptor());
    
    // Add logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        responseBody: true,
        requestBody: true,
        requestHeader: true,
      ));
    }
    
    // Set default headers
    final headers = <String, dynamic>{
      ...ApiConstants.defaultHeaders,
      ...?defaultHeaders,
    };
    _dio.options.headers.addAll(headers);
    
    _isInitialized = true;
    
    _logger.i('SecureApiClient initialized with base URL: $baseUrl');
  }

  /// Make a GET request
  Future<Response<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
  }) async {
    _ensureInitialized();
    
    try {
      final response = await _dio.get<T>(
        endpoint,
        queryParameters: queryParameters,
        options: _mergeOptions(options, headers),
      );
      
      _logger.i('GET $endpoint - Status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      _handleError(e, 'GET', endpoint);
      rethrow;
    }
  }

  /// Make a POST request
  Future<Response<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
  }) async {
    _ensureInitialized();
    
    try {
      final response = await _dio.post<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: _mergeOptions(options, headers),
      );
      
      _logger.i('POST $endpoint - Status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      _handleError(e, 'POST', endpoint);
      rethrow;
    }
  }

  /// Make a PUT request
  Future<Response<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
  }) async {
    _ensureInitialized();
    
    try {
      final response = await _dio.put<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: _mergeOptions(options, headers),
      );
      
      _logger.i('PUT $endpoint - Status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      _handleError(e, 'PUT', endpoint);
      rethrow;
    }
  }

  /// Make a DELETE request
  Future<Response<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
  }) async {
    _ensureInitialized();
    
    try {
      final response = await _dio.delete<T>(
        endpoint,
        queryParameters: queryParameters,
        options: _mergeOptions(options, headers),
      );
      
      _logger.i('DELETE $endpoint - Status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      _handleError(e, 'DELETE', endpoint);
      rethrow;
    }
  }

  /// Ensure the client is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('SecureApiClient not initialized. Call initialize() first.');
    }
  }

  /// Merge options with headers
  Options _mergeOptions(Options? options, Map<String, dynamic>? headers) {
    final mergedOptions = options?.copyWith() ?? Options();
    
    if (headers != null) {
      mergedOptions.headers = <String, dynamic>{
        ...?mergedOptions.headers,
        ...headers,
      };
    }
    
    // Add random header to prevent fingerprinting
    mergedOptions.headers = <String, dynamic>{
      ...?mergedOptions.headers,
      'X-Random-Identifier': Random().nextInt(1000000).toString(),
    };
    
    return mergedOptions;
  }

  /// Handle errors
  void _handleError(DioException error, String method, String endpoint) {
    _logger.e('$method $endpoint failed: ${error.message}', error: error);
    
    // Log additional details in debug mode
    if (kDebugMode) {
      _logger.d('Request: ${error.requestOptions.method} ${error.requestOptions.uri}');
      _logger.d('Response: ${error.response?.statusCode} ${error.response?.statusMessage}');
      _logger.d('Error data: ${error.response?.data}');
    }
  }

  /// Get Dio instance (use with caution)
  Dio get dio => _dio;
}