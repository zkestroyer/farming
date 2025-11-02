// lib/models/weather_models.dart

class Weather {
  final String locationName;
  final double currentTemp;
  final String currentCondition;
  final List<DailyForecast> dailyForecasts;

  Weather({
    required this.locationName,
    required this.currentTemp,
    required this.currentCondition,
    required this.dailyForecasts,
  });
}

class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String condition;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
  });
}