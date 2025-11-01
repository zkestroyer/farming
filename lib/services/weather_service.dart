// lib/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // --- Using WeatherAPI.com for this example ---
  // (Sign up at https://www.weatherapi.com/ to get your key)
  final String _apiKey = 'YOUR_WEATHER_API_KEY';
  final String _baseUrl = 'https://api.weatherapi.com/v1';

  /// Fetches current weather and 3-day forecast for a given location.
  Future<Map<String, dynamic>> getForecast(String location) async {
    if (_apiKey == 'YOUR_WEATHER_API_KEY') {
      return _mockWeatherResponse(location);
    }

    // This fetches current weather, forecast, and air quality all in one call
    final String url =
        '$_baseUrl/forecast.json?key=$_apiKey&q=$location&days=3&aqi=no&alerts=no';

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load weather: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  /// Mock response for offline demo
  Map<String, dynamic> _mockWeatherResponse(String location) {
    return {
      "location": {"name": location, "region": "Punjab", "country": "Pakistan"},
      "current": {
        "temp_c": 34.0,
        "is_day": 1,
        "condition": {"text": "Sunny", "icon": "//cdn.weatherapi.com/weather/64x64/day/113.png"},
        "humidity": 25,
      },
      "forecast": {
        "forecastday": [
          {
            "date": "2025-11-01",
            "day": {
              "maxtemp_c": 35.0,
              "mintemp_c": 22.0,
              "condition": {"text": "Sunny"}
            }
          },
          {
            "date": "2025-11-02",
            "day": {
              "maxtemp_c": 34.0,
              "mintemp_c": 21.0,
              "condition": {"text": "Partly cloudy"}
            }
          },
          {
            "date": "2025-11-03",
            "day": {
              "maxtemp_c": 33.0,
              "mintemp_c": 20.0,
              "condition": {"text": "Patchy rain possible"}
            }
          }
        ]
      }
    };
  }
}