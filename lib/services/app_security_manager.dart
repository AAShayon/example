import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSecurityManager {
  static final AppSecurityManager _instance = AppSecurityManager._internal();
  factory AppSecurityManager() => _instance;
  AppSecurityManager._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isTampered = false;
  String? _appSignature;

  // Initialize security checks
  Future<void> initialize() async {
    await _performSecurityChecks();
  }

  // Perform various security checks
  Future<void> _performSecurityChecks() async {
    // Skip security checks in debug mode
    if (kDebugMode) {
      return;
    }

    // Check for rooted/jailbroken device
    if (await _isDeviceRooted()) {
      _isTampered = true;
    }

    // Check for debugger attachment
    if (await _isDebuggerAttached()) {
      _isTampered = true;
    }

    // Store initial app signature
    await _storeAppSignature();
  }

  // Check if device is rooted (Android) or jailbroken (iOS)
  Future<bool> _isDeviceRooted() async {
    if (Platform.isAndroid) {
      // Check for common root files/directories
      final rootFiles = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
        '/su/bin/su'
      ];

      for (final file in rootFiles) {
        if (await File(file).exists()) {
          return true;
        }
      }

      // Check for root packages
      try {
        final packages = await _getInstalledPackages();
        if (packages.contains('com.noshufou.android.su') ||
            packages.contains('com.thirdparty.superuser') ||
            packages.contains('eu.chainfire.supersu')) {
          return true;
        }
      } catch (e) {
        // If we can't check packages, assume device might be compromised
        return true;
      }
    } else if (Platform.isIOS) {
      // Check for jailbreak indicators
      final jailbreakFiles = [
        '/Applications/Cydia.app',
        '/Library/MobileSubstrate/MobileSubstrate.dylib',
        '/bin/bash',
        '/usr/sbin/sshd',
        '/etc/apt'
      ];

      for (final file in jailbreakFiles) {
        if (await File(file).exists()) {
          return true;
        }
      }
    }

    return false;
  }

  // Get installed packages (Android only)
  Future<List<String>> _getInstalledPackages() async {
    // This is a simplified implementation
    // In a real app, you would use platform channels to get this information
    return [];
  }

  // Check if debugger is attached
  Future<bool> _isDebuggerAttached() async {
    // In a real implementation, you would use platform channels
    // to check for debugger attachment
    return false;
  }

  // Store app signature for integrity checking
  Future<void> _storeAppSignature() async {
    // Generate a pseudo app signature
    final signature = _generateAppSignature();
    await _secureStorage.write(key: 'app_signature', value: signature);
    _appSignature = signature; // Cache the signature
  }

  // Generate app signature
  String _generateAppSignature() {
    // Return cached signature if available
    if (_appSignature != null) {
      return _appSignature!;
    }
    
    // In a real implementation, you would generate a signature based on
    // app files, certificates, etc.
    // For now, we'll generate a consistent signature based on app properties
    final appId = 'com.example.example'; // Your app's package name/bundle ID
    final version = '1.0.0'; // Your app's version
    final signatureBase = '$appId-$version';
    
    // Create a consistent hash from the app properties
    final bytes = utf8.encode(signatureBase);
    final hash = sha256.convert(bytes);
    return base64Url.encode(hash.bytes);
  }

  // Verify app integrity
  Future<bool> verifyAppIntegrity() async {
    // Skip integrity check in debug mode
    if (kDebugMode) {
      return true;
    }

    try {
      final storedSignature = await _secureStorage.read(key: 'app_signature');
      if (storedSignature == null) {
        return false;
      }

      // Generate a new signature and compare with stored one
      final currentSignature = _generateAppSignature();
      return storedSignature == currentSignature;
    } catch (e) {
      return false;
    }
  }

  // Check if app has been tampered with
  bool isAppTampered() {
    // Skip tamper check in debug mode
    if (kDebugMode) {
      return false;
    }
    return _isTampered;
  }

  // Add security headers to HTTP requests
  Map<String, String> getSecurityHeaders() {
    return {
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

  // Obfuscate sensitive data
  String obfuscateString(String input) {
    // Simple obfuscation - in a real app, use more sophisticated methods
    final random = Random.secure();
    final values = List<int>.generate(input.length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  // Generate secure random string
  String generateSecureRandomString(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  // Clear all secure data
  Future<void> clearAllSecureData() async {
    await _secureStorage.deleteAll();
  }
}