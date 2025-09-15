import 'package:dio/dio.dart';
import 'package:example/constants/api_constants.dart';
import 'package:example/services/weather_api_client.dart';
import 'package:example/services/app_security_manager.dart';

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  final WeatherApiClient _httpClient = WeatherApiClient();
  final AppSecurityManager _securityManager = AppSecurityManager();

  Future<void> initialize() async {
    await _httpClient.initialize();
    await _securityManager.initialize();
    
    // Test API key retrieval (we'll do this through the http client)
    // The actual test will happen when the client tries to get the API key
  }

  Future<Map<String, dynamic>> getForecast({
    required String location,
    int days = 7,
    bool alerts = true,
    bool aqi = true,
  }) async {
    try {
      final response = await _httpClient.get(
        ApiConstants.forecastEndpoint,
        queryParameters: {
          'q': location,
          'days': days,
          'alerts': alerts,
          'aqi': aqi,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
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
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw Exception(errorMessage);
    }
  }
}