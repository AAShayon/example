class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? metadata;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.metadata,
  });

  /// Create success response
  factory ApiResponse.success(T data, {int? statusCode, Map<String, dynamic>? metadata}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      statusCode: statusCode,
      metadata: metadata,
    );
  }

  /// Create error response
  factory ApiResponse.error(String message, {int? statusCode, Map<String, dynamic>? metadata}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      metadata: metadata,
    );
  }

  /// Create from Dio response
  factory ApiResponse.fromDioResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      // Check if it's a success response
      if (response.containsKey('data') || response.containsKey('result')) {
        return ApiResponse<T>.success(response as T);
      }
      
      // Check if it's an error response
      if (response.containsKey('error') || response.containsKey('message')) {
        final errorMessage = response['error']?.toString() ?? response['message']?.toString() ?? 'Unknown error';
        return ApiResponse<T>.error(errorMessage);
      }
    }
    
    // Default success response
    return ApiResponse<T>.success(response as T);
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, data: $data, message: $message, statusCode: $statusCode)';
  }
}