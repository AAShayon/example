import 'package:flutter/material.dart';
import 'package:example/services/weather_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _locationController = TextEditingController();
  Map<String, dynamic>? _forecastData;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _getForecast() async {
    if (_locationController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a location';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await WeatherService().getForecast(
        location: _locationController.text,
      );
      
      setState(() {
        _forecastData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildWeatherCard(Map<String, dynamic> dayData) {
    final date = DateTime.parse(dayData['date']);
    final day = dayData['day'];
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${day['maxtemp_c'].round()}°C',
                  style: TextStyle(fontSize: 24, color: Colors.red),
                ),
                Text(
                  '${day['mintemp_c'].round()}°C',
                  style: TextStyle(fontSize: 24, color: Colors.blue),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              day['condition']['text'],
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast'),
        backgroundColor: Color(0xFF4A90E2),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'Enter city name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _getForecast,
                  child: _isLoading 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ),
          if (_forecastData != null)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Location: ${_forecastData!['location']['name']}, ${_forecastData!['location']['country']}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _forecastData!['forecast']['forecastday'].length,
                      itemBuilder: (context, index) {
                        return _buildWeatherCard(
                          _forecastData!['forecast']['forecastday'][index],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}