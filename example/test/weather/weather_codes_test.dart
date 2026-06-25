import 'package:flutter_test/flutter_test.dart';
import 'dart:ui';

import 'package:liquid_glass_native_example/weather/shared/weather_codes.dart';

void main() {
  group('WeatherVisual', () {
    test('creates with label, gradient, and sfSymbol', () {
      final gradient = LinearGradient(
        colors: [Color(0xFF2E8BFF), Color(0xFF6FB8FF)],
      );
      final visual = WeatherVisual(
        label: 'Clear',
        gradient: gradient,
        sfSymbol: 'sun.max',
      );
      expect(visual.label, 'Clear');
      expect(visual.gradient, gradient);
      expect(visual.sfSymbol, 'sun.max');
    });
  });

  group('weatherVisualFromCode', () {
    group('clear conditions (0-1)', () {
      test('code 0 day', () {
        final v = weatherVisualFromCode(0, true);
        expect(v.label, contains('Clear'));
        expect(v.gradient.colors.first, const Color(0xFF2E8BFF));
      });

      test('code 0 night', () {
        final v = weatherVisualFromCode(0, false);
        expect(v.label, contains('Clear'));
        expect(v.gradient.colors.first, const Color(0xFF0A0E27));
      });

      test('code 1 day', () {
        final v = weatherVisualFromCode(1, true);
        expect(v.label, contains('Clear'));
      });
    });

    group('cloudy conditions (2-3)', () {
      test('code 2 day', () {
        final v = weatherVisualFromCode(2, true);
        expect(v.label, contains('Cloudy'));
        expect(v.sfSymbol, 'cloud');
      });

      test('code 3 night', () {
        final v = weatherVisualFromCode(3, false);
        expect(v.label, contains('Cloudy'));
        expect(v.gradient.colors.first, const Color(0xFF1A2332));
      });
    });

    group('fog (45, 48)', () {
      test('code 45 day', () {
        final v = weatherVisualFromCode(45, true);
        expect(v.label, contains('Fog'));
        expect(v.sfSymbol, 'cloud.fog');
      });

      test('code 48 night', () {
        final v = weatherVisualFromCode(48, false);
        expect(v.label, contains('Fog'));
      });
    });

    group('drizzle (51, 53, 55)', () {
      test('code 51 returns drizzle', () {
        final v = weatherVisualFromCode(51, true);
        expect(v.label, contains('Drizzle'));
        expect(v.sfSymbol, 'cloud.drizzle');
      });

      test('code 55 day gradient starts with day color', () {
        final v = weatherVisualFromCode(55, true);
        expect(v.gradient.colors.first, const Color(0xFF7FA1C3));
      });
    });

    group('rain (61, 63, 65)', () {
      test('code 61 rain', () {
        final v = weatherVisualFromCode(61, true);
        expect(v.label, contains('Rain'));
        expect(v.sfSymbol, 'cloud.rain');
      });

      test('code 65 night', () {
        final v = weatherVisualFromCode(65, false);
        expect(v.label, contains('Rain'));
        expect(v.gradient.colors.first, const Color(0xFF0F283A));
      });
    });

    group('snow (71, 73, 75, 77)', () {
      test('code 71 snow', () {
        final v = weatherVisualFromCode(71, true);
        expect(v.label, contains('Snow'));
        expect(v.sfSymbol, 'cloud.snow');
      });

      test('code 77 snow', () {
        final v = weatherVisualFromCode(77, true);
        expect(v.label, contains('Snow'));
      });
    });

    group('showers (80, 81, 82)', () {
      test('code 80 showers', () {
        final v = weatherVisualFromCode(80, true);
        expect(v.label, contains('Shower'));
        expect(v.sfSymbol, 'cloud.heavyrain');
      });
    });

    group('thunderstorm (95, 96, 99)', () {
      test('code 95 thunderstorm', () {
        final v = weatherVisualFromCode(95, true);
        expect(v.label, contains('Thunderstorm'));
        expect(v.sfSymbol, 'cloud.bolt.rain');
      });

      test('code 99 thunderstorm', () {
        final v = weatherVisualFromCode(99, true);
        expect(v.label, contains('Thunderstorm'));
      });
    });

    group('unknown code', () {
      test('returns clear for unrecognized code', () {
        final v = weatherVisualFromCode(-1, true);
        expect(v.label, contains('Clear'));
      });
    });
  });
}
