import 'package:flutter/material.dart';
import 'package:example/services/weather_service.dart';
import 'package:example/services/app_security_manager.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize weather service and security manager
      await WeatherService().initialize();
      
      // Additional security check
      if (AppSecurityManager().isAppTampered()) {
        _showSecurityAlert();
        return;
      }
      
      // Simulate loading time
      await Future.delayed(Duration(seconds: 2));
      
      // Navigate to home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      // Handle initialization error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize app: $e')),
      );
    }
  }

  void _showSecurityAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Security Alert'),
          content: Text('Security violation detected. The app cannot run on this device.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Close the app
                // In a real app, you would use platform channels to close the app
              },
              child: Text('Close App'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF5E60CE),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'Weather Forecast',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}