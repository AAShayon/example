import 'package:dio/dio.dart';
import 'package:example/constants/api_constants.dart';
import 'package:example/services/security_service.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class WeatherApiClient {
  static final WeatherApiClient _instance = WeatherApiClient._internal();
  factory WeatherApiClient() => _instance;
  WeatherApiClient._internal();

  late Dio _dio;
  final SecurityService _securityService = SecurityService();

  Future<void> initialize() async {
    _dio = Dio();
    // Add a simple interceptor for logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LoggingInterceptor());
    }
    
    // Test API key retrieval in debug mode
    if (kDebugMode) {
      final testKey = await _securityService.getApiKey();
      print('WeatherApiClient initialized with API key: "$testKey" (length: ${testKey.length})');
    }
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    // Get the API key
    final apiKey = await _securityService.getApiKey();
    if (apiKey.isEmpty) {
      throw Exception('API key is empty');
    }
    
    // Add API key to query parameters
    final params = Map<String, dynamic>.from(queryParameters ?? {});
    params['key'] = apiKey;
    
    // For debugging - remove in production
    if (kDebugMode) {
      print('Making request to: ${ApiConstants.baseUrl}$endpoint');
      print('With parameters: $params');
    }
    
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}$endpoint',
        queryParameters: params,
      );
      
      return response;
    } on DioException catch (e) {
      // Handle error with more specific messages
      String errorMessage = 'Failed to fetch weather data';
      
      if (e.response?.statusCode == 401) {
        errorMessage = 'Invalid API key. Please check your API key.';
      } else if (e.response?.statusCode == 400) {
        errorMessage = 'Bad request. Please check the location name.';
      } else if (e.response?.statusCode == 403) {
        errorMessage = 'API key forbidden. Please check your API key permissions.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Network timeout. Please check your internet connection.';
      }
      
      throw Exception('$errorMessage: ${e.message}');
    }
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // In debug mode, log requests
    if (kDebugMode) {
      print('REQUEST: ${options.method} ${options.uri}');
      print('Headers: ${options.headers}');
      print('Query Parameters: ${options.queryParameters}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // In debug mode, log responses
    if (kDebugMode) {
      print('RESPONSE: ${response.statusCode} ${response.realUri}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // In debug mode, log errors
    if (kDebugMode) {
      print('ERROR: ${err.message}');
      if (err.response != null) {
        print('Response status: ${err.response?.statusCode}');
        print('Response data: ${err.response?.data}');
      }
    }
    super.onError(err, handler);
  }
}