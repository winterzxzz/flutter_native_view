import 'package:flutter/material.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

import '../../shared/weather_codes.dart';
import '../../shared/formatters.dart';
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
          return LiquidGlassContainer(
            borderRadius: 14,
            child: SizedBox(
              width: 64,
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
                    _iconFromSfSymbol(visual.sfSymbol),
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
            ),
          );
        },
      ),
    );
  }
}

IconData _iconFromSfSymbol(String sfSymbol) {
  switch (sfSymbol) {
    case 'sun.max':
      return Icons.wb_sunny;
    case 'moon.stars':
      return Icons.nights_stay;
    case 'cloud':
      return Icons.cloud;
    case 'cloud.moon':
      return Icons.cloud;
    case 'cloud.fog':
      return Icons.foggy;
    case 'cloud.drizzle':
      return Icons.grain;
    case 'cloud.rain':
      return Icons.umbrella;
    case 'cloud.heavyrain':
      return Icons.thunderstorm;
    case 'cloud.snow':
      return Icons.ac_unit;
    case 'cloud.bolt.rain':
      return Icons.flash_on;
    default:
      return Icons.wb_sunny;
  }
}
