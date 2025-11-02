// lib/services/weather_service.dart
import 'dart:convert';
import 'dart:math'; // We need this for min/max
import 'package:http/http.dart' as http;

// Import our new models
import 'package:farming/models/weather_models.dart';

class WeatherService {
  final String _apiKey = 'fee1d96b1414c7187e5237cc5639e298';
  final String _baseUrl = 'https://api.openweathermap.org/';

  /// Fetches and parses the 5-day forecast.
  /// NOW RETURNS: A clean, custom `Weather` object.
  Future<Weather> getForecast(String location) async {
    if (_apiKey == 'YOUR_WEATHER_API_KEY') {
      // If we're mocking, we parse the mock response
      return _parseForecast(_mockWeatherResponse(location));
    }

    final String url =
        '$_baseUrl/data/2.5/forecast?q=$location&appid=$_apiKey&units=metric';

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        // Parse the real JSON response
        final rawData = jsonDecode(res.body) as Map<String, dynamic>;
        return _parseForecast(rawData);
      } else {
        print('Failed to load weather: ${res.statusCode} ${res.body}');
        throw Exception('Failed to load weather: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  /// This is our new parser function.
  /// It converts the complex OWM map into our simple Weather object.
  Weather _parseForecast(Map<String, dynamic> rawData) {
    // --- 1. Parse current conditions and location ---

    // Get location name from the 'city' object
    final String locationName = rawData['city']['name'];

    // Get current conditions from the *first* item in the list
    final currentData = rawData['list'][0];
    final double currentTemp = currentData['main']['temp'];
    final String currentCondition = currentData['weather'][0]['main'];

    // --- 2. Group 3-hour forecasts into daily forecasts ---

    // A map to hold data as we process it, e.g., "2025-11-02" -> data
    final Map<String, List<double>> dailyTemps = {};
    final Map<String, String> dailyConditions = {};

    for (var item in rawData['list']) {
      final double temp = item['main']['temp'];
      final String condition = item['weather'][0]['main'];
      
      // Get the date "YYYY-MM-DD" string from "dt_txt"
      final String date = item['dt_txt'].split(' ')[0];

      // If we don't have this date yet, create an entry
      if (dailyTemps[date] == null) {
        dailyTemps[date] = [];
      }

      // Add the temperature to that day's list
      dailyTemps[date]!.add(temp);

      // Store the condition for midday (around 12:00:00 or 15:00:00)
      // This is a simple way to get a representative condition for the day
      if (item['dt_txt'].contains("12:00:00")) {
        dailyConditions[date] = condition;
      }
      // Fallback if no 12:00:00 entry exists (e.g., first partial day)
       else if (!dailyConditions.containsKey(date)) {
        dailyConditions[date] = condition;
      }
    }

    // --- 3. Create the final DailyForecast objects ---

    final List<DailyForecast> forecasts = [];
    for (var date in dailyTemps.keys) {
      final List<double> temps = dailyTemps[date]!;
      
      // Use Dart's 'math' library to find min/max
      final double minTemp = temps.reduce(min);
      final double maxTemp = temps.reduce(max);

      forecasts.add(
        DailyForecast(
          // Convert the date string back to a DateTime object
          date: DateTime.parse(date),
          minTemp: minTemp,
          maxTemp: maxTemp,
          condition: dailyConditions[date] ?? "N/A", // Use fallback
        ),
      );
    }

    // --- 4. Return the final, clean Weather object ---
    return Weather(
      locationName: locationName,
      currentTemp: currentTemp,
      currentCondition: currentCondition,
      dailyForecasts: forecasts,
    );
  }

  /// Mock response for offline demo
  Map<String, dynamic> _mockWeatherResponse(String location) {
    // (This is the same mock data as before)
    return {
      "cod": "200",
      "message": 0,
      "cnt": 40,
      "list": [
        {
          "dt": 1730458800,
          "main": {"temp": 34.0, "temp_min": 33.0, "temp_max": 35.0},
          "weather": [{"main": "Clear", "description": "clear sky"}],
          "dt_txt": "2025-11-01 12:00:00"
        },
        {
          "dt": 1730469600,
          "main": {"temp": 33.5, "temp_min": 33.0, "temp_max": 34.0},
          "weather": [{"main": "Clouds", "description": "few clouds"}],
          "dt_txt": "2025-11-01 15:00:00"
        },
        // --- Day 2 ---
        {
          "dt": 1730545200,
          "main": {"temp": 28.0, "temp_min": 27.5, "temp_max": 28.0},
          "weather": [{"main": "Clouds", "description": "broken clouds"}],
          "dt_txt": "2025-11-02 12:00:00"
        },
        {
          "dt": 1730556000,
          "main": {"temp": 27.0, "temp_min": 26.0, "temp_max": 27.0},
          "weather": [{"main": "Rain", "description": "light rain"}],
          "dt_txt": "2025-11-02 15:00:00"
        }
        // ... etc ...
      ],
      "city": {"id": 12345, "name": location, "country": "PK"}
    };
  }
}