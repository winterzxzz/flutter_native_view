import 'package:flutter/material.dart';

import '../../domain/entities/current_weather.dart';
import '../../domain/entities/location.dart';
import '../../shared/formatters.dart';
import '../../shared/weather_codes.dart';

/// A card displaying the current weather for a location.
///
/// Pure leaf widget: takes entities + [TempUnit] as constructor args and
/// renders a big temperature focal point with supporting metrics.
class CurrentConditionsCard extends StatelessWidget {
  const CurrentConditionsCard({
    super.key,
    required this.weather,
    required this.location,
    required this.unit,
  });

  final CurrentWeather weather;
  final Location location;
  final TempUnit unit;

  @override
  Widget build(BuildContext context) {
    final WeatherVisual visual =
        weatherVisualFromCode(weather.weatherCode, weather.isDay);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${location.name}, ${location.country}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              visual.label,
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Large temperature focal point
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                formatTemp(weather.tempC, unit),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 96,
                  fontWeight: FontWeight.w200,
                  height: 0.95,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Metrics row: feels like, humidity, wind
            DefaultTextStyle(
              style: const TextStyle(color: Colors.white60, fontSize: 13),
              child: Row(
                children: [
                  _Metric(label: 'Feels like', value: formatTemp(weather.feelsLikeC, unit)),
                  const SizedBox(width: 16),
                  _Metric(label: 'Humidity', value: '${weather.humidity.toInt()}%'),
                  const SizedBox(width: 16),
                  _Metric(label: 'Wind', value: '${weather.windKph.toInt()} km/h'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }
}
