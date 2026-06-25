import 'package:flutter/material.dart';

import '../../shared/weather_codes.dart';
import '../../shared/formatters.dart';
import '../../shared/icons.dart';
import '../../domain/entities/daily_forecast.dart';

class DailyList extends StatelessWidget {
  const DailyList({
    super.key,
    required this.daily,
    required this.unit,
  });

  final List<DailyForecast> daily;
  final TempUnit unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (final day in daily)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Text(
                        formatDay(day.date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      iconForSfSymbol(
                        weatherVisualFromCode(day.weatherCode, true).sfSymbol,
                      ),
                      color: Colors.white,
                      size: 22,
                    ),
                    const Spacer(),
                    Text(
                      formatTemp(day.maxC, unit),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      formatTemp(day.minC, unit),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
