class ApiConstants {
  // These will be overridden by the consumer app
  static String baseUrl = "";
  static String apiKey = "";
  
  // Security constants
  static const String secureStorageKey = "enterprise_api_key";
  static const String secureStorageSalt = "enterprise_api_salt";
  
  // Default endpoints (can be customized)
  static const String weatherEndpoint = "weather";
  static const String forecastEndpoint = "forecast";
  
  // Security headers
  static const Map<String, String> defaultHeaders = {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'X-Permitted-Cross-Domain-Policies': 'none',
    'Referrer-Policy': 'no-referrer',
    'Cache-Control': 'no-store, no-cache, must-revalidate, proxy-revalidate',
    'Pragma': 'no-cache',
    'Expires': '0',
  };
}