import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_native_example/weather/data/models/geo_location_model.dart';
import 'package:liquid_glass_native_example/weather/data/models/forecast_model.dart';
import 'package:liquid_glass_native_example/weather/domain/entities/location.dart';
import 'package:liquid_glass_native_example/weather/domain/entities/weather_bundle.dart';

String _pad(int n) => n.toString().padLeft(2, '0');

void main() {
  group('GeoLocationModel', () {
    test('fromJson parses valid response correctly', () {
      final json = {
        'name': 'London',
        'country': 'United Kingdom',
        'admin1': 'England',
        'latitude': 51.5074,
        'longitude': -0.1278,
        'timezone': 'Europe/London',
      };

      final model = GeoLocationModel.fromJson(json);
      expect(model.name, 'London');
      expect(model.country, 'United Kingdom');
      expect(model.admin1, 'England');
      expect(model.latitude, 51.5074);
      expect(model.longitude, -0.1278);
      expect(model.timezone, 'Europe/London');
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'name': 'Tokyo',
        'latitude': 35.6762,
        'longitude': 139.6503,
      };

      final model = GeoLocationModel.fromJson(json);
      expect(model.name, 'Tokyo');
      expect(model.country, '');
      expect(model.admin1, '');
      expect(model.timezone, '');
    });

    test('toEntity converts to Location entity', () {
      final json = {
        'name': 'Paris',
        'country': 'France',
        'admin1': 'Île-de-France',
        'latitude': 48.8566,
        'longitude': 2.3522,
        'timezone': 'Europe/Paris',
      };

      final model = GeoLocationModel.fromJson(json);
      final entity = model.toEntity();

      expect(entity, isA<Location>());
      expect(entity.name, 'Paris');
      expect(entity.country, 'France');
      expect(entity.admin1, 'Île-de-France');
      expect(entity.latitude, 48.8566);
      expect(entity.longitude, 2.3522);
      expect(entity.timezone, 'Europe/Paris');
    });
  });

  group('ForecastModel', () {
    final now = DateTime.now();
    final hour0 = now.add(const Duration(hours: 1));
    final hour1 = now.add(const Duration(hours: 2));
    final hour2 = now.add(const Duration(hours: 3));
    final today = '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
    final tomorrow = now.add(const Duration(days: 1));
    final dayAfter = now.add(const Duration(days: 2));
    final tomorrowStr =
        '${tomorrow.year}-${_pad(tomorrow.month)}-${_pad(tomorrow.day)}';
    final dayAfterStr =
        '${dayAfter.year}-${_pad(dayAfter.month)}-${_pad(dayAfter.day)}';

    final forecastJson = {
      'current': {
        'time': '${today}T12:00',
        'temperature_2m': 22.5,
        'apparent_temperature': 20.1,
        'relative_humidity_2m': 65.0,
        'wind_speed_10m': 12.3,
        'weather_code': 2,
        'is_day': 1,
      },
      'hourly': {
        'time': [
          hour0.toIso8601String(),
          hour1.toIso8601String(),
          hour2.toIso8601String(),
        ],
        'temperature_2m': [15.0, 14.5, 14.0],
        'weather_code': [2, 2, 3],
      },
      'daily': {
        'time': [today, tomorrowStr, dayAfterStr],
        'weather_code': [2, 1, 3],
        'temperature_2m_max': [25.0, 26.5, 24.0],
        'temperature_2m_min': [14.0, 15.5, 13.0],
      },
    };

    test('fromJson parses current weather correctly', () {
      final model = ForecastModel.fromJson(forecastJson);

      expect(model.current.tempC, 22.5);
      expect(model.current.feelsLikeC, 20.1);
      expect(model.current.humidity, 65.0);
      expect(model.current.windKph, 12.3);
      expect(model.current.weatherCode, 2);
      expect(model.current.isDay, true);
    });

    test('fromJson parses daily forecasts correctly', () {
      final model = ForecastModel.fromJson(forecastJson);

      expect(model.daily.length, 3);
      expect(model.daily[0].weatherCode, 2);
      expect(model.daily[0].maxC, 25.0);
      expect(model.daily[0].minC, 14.0);
      expect(model.daily[1].weatherCode, 1);
      expect(model.daily[1].maxC, 26.5);
    });

    test('toEntity produces WeatherBundle', () {
      final location = Location(
        name: 'London',
        country: 'United Kingdom',
        admin1: 'England',
        latitude: 51.5,
        longitude: -0.1,
        timezone: 'Europe/London',
      );

      final model = ForecastModel.fromJson(forecastJson);
      final bundle = model.toEntity(location);

      expect(bundle, isA<WeatherBundle>());
      expect(bundle.location.name, 'London');
      expect(bundle.current.tempC, 22.5);
      expect(bundle.hourly.length, 3);
      expect(bundle.daily.length, 3);
    });
  });
}
