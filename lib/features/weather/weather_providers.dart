import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// ── Models ──────────────────────────────────────────────────────────────────

class WeatherData {
  final double temperatureC;
  final double windSpeedKmh;
  final int weatherCode;
  final List<DailyForecast> forecast;

  const WeatherData({
    required this.temperatureC,
    required this.windSpeedKmh,
    required this.weatherCode,
    required this.forecast,
  });

  String get weatherLabel => _wmoLabel(weatherCode);
  String get weatherIcon => _wmoIcon(weatherCode);
}

class DailyForecast {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final double snowfallCm;
  final int weatherCode;

  const DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.snowfallCm,
    required this.weatherCode,
  });

  String get weatherIcon => _wmoIcon(weatherCode);
}

// ── WMO code mapping ────────────────────────────────────────────────────────

String _wmoLabel(int code) {
  if (code == 0) return 'Clear';
  if (code <= 3) return 'Cloudy';
  if (code <= 48) return 'Fog';
  if (code <= 55) return 'Drizzle';
  if (code <= 65) return 'Rain';
  if (code <= 77) return 'Snow';
  if (code <= 86) return 'Snow showers';
  if (code <= 99) return 'Thunderstorm';
  return 'Unknown';
}

String _wmoIcon(int code) {
  if (code == 0) return '☀️';
  if (code <= 3) return '⛅';
  if (code <= 48) return '🌫️';
  if (code <= 55) return '🌧️';
  if (code <= 65) return '🌧️';
  if (code <= 77) return '❄️';
  if (code <= 86) return '🌨️';
  if (code <= 99) return '⛈️';
  return '🌡️';
}

// ── Provider ────────────────────────────────────────────────────────────────

/// Fetches weather for given (lat, lon). Cached in-memory by Riverpod.
final weatherProvider =
    FutureProvider.family<WeatherData, ({double lat, double lon})>(
  (ref, coords) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=${coords.lat}'
      '&longitude=${coords.lon}'
      '&current=temperature_2m,wind_speed_10m,weather_code'
      '&daily=temperature_2m_max,temperature_2m_min,weather_code,snowfall_sum'
      '&timezone=auto',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Weather API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>;

    final times = (daily['time'] as List).cast<String>();
    final maxTemps = (daily['temperature_2m_max'] as List).cast<num>();
    final minTemps = (daily['temperature_2m_min'] as List).cast<num>();
    final codes = (daily['weather_code'] as List).cast<num>();
    final snowfall = (daily['snowfall_sum'] as List).cast<num>();

    final forecasts = <DailyForecast>[];
    for (var i = 0; i < times.length; i++) {
      forecasts.add(DailyForecast(
        date: DateTime.parse(times[i]),
        tempMax: maxTemps[i].toDouble(),
        tempMin: minTemps[i].toDouble(),
        snowfallCm: snowfall[i].toDouble(),
        weatherCode: codes[i].toInt(),
      ));
    }

    return WeatherData(
      temperatureC: (current['temperature_2m'] as num).toDouble(),
      windSpeedKmh: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      forecast: forecasts,
    );
  },
);

/// Default location: Isola 2000 (used when GPS is unavailable).
const defaultWeatherCoords = (lat: 44.19, lon: 7.16);
