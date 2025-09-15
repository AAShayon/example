import 'package:dio/dio.dart';
import 'package:example/constants/api_constants.dart';
import 'package:example/services/secure_http_client.dart';
import 'package:example/services/app_security_manager.dart';

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  final SecureHttpClient _httpClient = SecureHttpClient();
  final AppSecurityManager _securityManager = AppSecurityManager();

  Future<void> initialize() async {
    await _httpClient.initialize();
    await _securityManager.initialize();
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
      throw Exception('Failed to fetch weather data: ${e.message}');
    }
  }
}