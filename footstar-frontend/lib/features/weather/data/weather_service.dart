import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/weather_model.dart';

class WeatherService {
  /// Fetches weather for a specific [date] and coordinates ([lat], [lng]).
  /// Open-Meteo allows up to 16 days of forecast.
  Future<WeatherModel?> fetchWeatherForMatch(
    DateTime date,
    double lat,
    double lng,
  ) async {
    try {
      // Open-Meteo requires dates in YYYY-MM-DD
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lng'
        '&hourly=temperature_2m,precipitation,weather_code'
        '&timezone=auto'
        '&start_date=$dateString&end_date=$dateString',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['hourly'] != null) {
          final hourlyData = data['hourly'];
          final times = hourlyData['time'] as List;

          // Find the hour closest to the match time
          int bestMatchIndex = 0;
          int minDiff = 24 * 60; // Max diff in minutes

          for (int i = 0; i < times.length; i++) {
            final timeStr = times[i] as String;
            final forecastTime = DateTime.parse(timeStr).toLocal();

            final diff = (forecastTime.hour - date.hour).abs();
            if (diff < minDiff) {
              minDiff = diff;
              bestMatchIndex = i;
            }
          }

          return WeatherModel.fromJson(hourlyData, bestMatchIndex);
        }
      }
      return null;
    } catch (e) {
      // Silently fail for weather, as it's not a critical feature
      return null;
    }
  }
}
