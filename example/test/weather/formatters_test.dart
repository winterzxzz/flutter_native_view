import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_native_example/weather/shared/formatters.dart';

void main() {
  group('TempUnit', () {
    test('has celsius and fahrenheit values', () {
      expect(TempUnit.values, hasLength(2));
      expect(TempUnit.celsius, isA<TempUnit>());
      expect(TempUnit.fahrenheit, isA<TempUnit>());
    });
  });

  group('roundTemp', () {
    test('rounds to nearest integer', () {
      expect(roundTemp(22.3), 22);
      expect(roundTemp(22.7), 23);
      expect(roundTemp(-1.5), -2);
    });

    test('handles whole numbers', () {
      expect(roundTemp(0), 0);
      expect(roundTemp(100), 100);
      expect(roundTemp(-10), -10);
    });
  });

  group('celsiusToFahrenheit', () {
    test('converts 0°C to 32°F', () {
      expect(celsiusToFahrenheit(0), closeTo(32, 0.1));
    });

    test('converts 100°C to 212°F', () {
      expect(celsiusToFahrenheit(100), closeTo(212, 0.1));
    });

    test('converts -40°C to -40°F', () {
      expect(celsiusToFahrenheit(-40), closeTo(-40, 0.1));
    });

    test('converts 22°C to 71.6°F', () {
      expect(celsiusToFahrenheit(22), closeTo(71.6, 0.1));
    });
  });

  group('formatTemp', () {
    test('returns rounded integer with °C for celsius', () {
      expect(formatTemp(22.7, TempUnit.celsius), '23°C');
    });

    test('returns rounded integer with °F for fahrenheit', () {
      expect(formatTemp(22, TempUnit.fahrenheit), '72°F');
    });

    test('returns 0°C for zero celsius', () {
      expect(formatTemp(0, TempUnit.celsius), '0°C');
    });

    test('returns 32°F for zero celsius in fahrenheit', () {
      expect(formatTemp(0, TempUnit.fahrenheit), '32°F');
    });
  });

  group('formatHour', () {
    test('formats midnight as 0:00', () {
      final dt = DateTime(2026, 6, 25, 0, 0);
      expect(formatHour(dt), '0:00');
    });

    test('formats noon as 12:00', () {
      final dt = DateTime(2026, 6, 25, 12, 0);
      expect(formatHour(dt), '12:00');
    });

    test('formats afternoon', () {
      final dt = DateTime(2026, 6, 25, 14, 30);
      expect(formatHour(dt), '14:30');
    });

    test('formats single-digit hour with leading minute zero', () {
      final dt = DateTime(2026, 6, 25, 9, 5);
      expect(formatHour(dt), '9:05');
    });
  });

  group('formatDay', () {
    test('returns Mon for Monday', () {
      final dt = DateTime(2026, 6, 22);
      expect(formatDay(dt), 'Mon');
    });

    test('returns Tue for Tuesday', () {
      final dt = DateTime(2026, 6, 23);
      expect(formatDay(dt), 'Tue');
    });

    test('returns Wed for Wednesday', () {
      final dt = DateTime(2026, 6, 24);
      expect(formatDay(dt), 'Wed');
    });

    test('returns Thu for Thursday', () {
      final dt = DateTime(2026, 6, 25);
      expect(formatDay(dt), 'Thu');
    });

    test('returns Fri for Friday', () {
      final dt = DateTime(2026, 6, 26);
      expect(formatDay(dt), 'Fri');
    });

    test('returns Sat for Saturday', () {
      final dt = DateTime(2026, 6, 27);
      expect(formatDay(dt), 'Sat');
    });

    test('returns Sun for Sunday', () {
      final dt = DateTime(2026, 6, 28);
      expect(formatDay(dt), 'Sun');
    });
  });
}
