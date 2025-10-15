import 'dart:math';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:secure_enterprise_api/utils/constants.dart';


class SecurityInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Add security headers
      options.headers.addAll(ApiConstants.defaultHeaders);
      
      // Add random identifier to prevent fingerprinting
      options.headers['X-Random-Identifier'] = Random().nextInt(1000000).toString();
      
      // Add request signature for integrity verification
      final signature = _generateSignature(options);
      options.headers['X-Request-Signature'] = signature;
      
    } catch (e) {
      // Don't fail the request if we can't add security features
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    try {
      // Add security headers to response
      ApiConstants.defaultHeaders.forEach((key, value) {
        response.headers.set(key, value);
      });
    } catch (e) {
      // Don't fail the response if we can't add security features
    }
    
    super.onResponse(response, handler);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    // Log security-related errors
    super.onError(err, handler);
  }

  /// Generate request signature for integrity verification
  String _generateSignature(RequestOptions options) {
    try {
      // Create signature base string
      final uri = options.uri;
      final method = options.method;
      final timestamp = options.queryParameters['timestamp'] ?? '';
      
      // Sort query parameters for consistent signature
      final sortedParams = Map.fromEntries(
        options.queryParameters.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key))
      );
      
      final paramString = sortedParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      // Create signature string
      final signatureBase = '$method|$uri|$paramString|$timestamp';
      
      // Generate SHA256 hash
      final bytes = utf8.encode(signatureBase);
      final digest = sha256.convert(bytes);
      
      return digest.toString();
    } catch (e) {
      // Return empty signature if generation fails
      return '';
    }
  }
}