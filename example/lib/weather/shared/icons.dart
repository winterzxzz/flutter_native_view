import 'package:flutter/material.dart';

IconData iconForSfSymbol(String sfSymbol) {
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
