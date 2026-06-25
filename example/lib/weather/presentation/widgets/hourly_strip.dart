import 'package:flutter/material.dart';

import '../../shared/weather_codes.dart';
import '../../shared/formatters.dart';
import '../../shared/icons.dart';
import '../../domain/entities/hourly_forecast.dart';

class HourlyStrip extends StatelessWidget {
  const HourlyStrip({
    super.key,
    required this.hourly,
    required this.unit,
  });

  final List<HourlyForecast> hourly;
  final TempUnit unit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: hourly.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final h = hourly[index];
          final visual = weatherVisualFromCode(h.weatherCode, true);
          return Container(
            width: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formatHour(h.time),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  iconForSfSymbol(visual.sfSymbol),
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  formatTemp(h.tempC, unit),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
