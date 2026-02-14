import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'weather_providers.dart';

/// Compact weather card for profile / session screens.
class WeatherWidget extends ConsumerWidget {
  final double? latitude;
  final double? longitude;

  const WeatherWidget({super.key, this.latitude, this.longitude});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lat = latitude ?? defaultWeatherCoords.lat;
    final lon = longitude ?? defaultWeatherCoords.lon;
    final weatherAsync = ref.watch(weatherProvider((lat: lat, lon: lon)));
    final theme = Theme.of(context);

    return weatherAsync.when(
      data: (w) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current conditions row
            Row(
              children: [
                Text(w.weatherIcon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${w.temperatureC.toStringAsFixed(0)}°C',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      w.weatherLabel,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.air, color: Colors.white38, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${w.windSpeedKmh.toStringAsFixed(0)} km/h',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (w.forecast.isNotEmpty && w.forecast[0].snowfallCm > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('❄️', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            '${w.forecast[0].snowfallCm.toStringAsFixed(1)} cm',
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),

            // 3-day forecast strip
            if (w.forecast.length >= 3) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 10),
              Row(
                children: w.forecast.take(3).map((day) {
                  return Expanded(
                    child: Column(
                      children: [
                        Text(
                          DateFormat('E').format(day.date),
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 10),
                        ),
                        const SizedBox(height: 4),
                        Text(day.weatherIcon,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          '${day.tempMax.toStringAsFixed(0)}°',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${day.tempMin.toStringAsFixed(0)}°',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11),
                        ),
                        if (day.snowfallCm > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${day.snowfallCm.toStringAsFixed(0)}cm',
                            style: const TextStyle(
                                color: Color(0xFF4FC3F7), fontSize: 10),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      loading: () => Container(
        height: 80,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
