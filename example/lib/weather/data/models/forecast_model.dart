import '../../domain/entities/current_weather.dart';
import '../../domain/entities/daily_forecast.dart';
import '../../domain/entities/hourly_forecast.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/weather_bundle.dart';

class ForecastModel {
  const ForecastModel({
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    return ForecastModel(
      current: _parseCurrent(current),
      hourly: _parseHourly(hourly),
      daily: _parseDaily(daily),
    );
  }

  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  WeatherBundle toEntity(Location location) => WeatherBundle(
        location: location,
        current: current,
        hourly: hourly,
        daily: daily,
      );

  static CurrentWeather _parseCurrent(Map<String, dynamic> json) {
    return CurrentWeather(
      tempC: (json['temperature_2m'] as num).toDouble(),
      feelsLikeC: (json['apparent_temperature'] as num).toDouble(),
      humidity: (json['relative_humidity_2m'] as num).toDouble(),
      windKph: (json['wind_speed_10m'] as num).toDouble(),
      weatherCode: json['weather_code'] as int,
      isDay: json['is_day'] as int == 1,
    );
  }

  static List<HourlyForecast> _parseHourly(Map<String, dynamic> json) {
    final times = json['time'] as List<dynamic>;
    final temps = json['temperature_2m'] as List<dynamic>;
    final codes = json['weather_code'] as List<dynamic>;

    final now = DateTime.now();
    final cutoff = now.add(const Duration(hours: 24));
    final forecasts = <HourlyForecast>[];

    for (var i = 0; i < times.length; i++) {
      final time = DateTime.parse(times[i] as String);
      if (time.isAfter(cutoff)) break;
      if (time.isBefore(now)) continue;

      forecasts.add(HourlyForecast(
        time: time,
        tempC: (temps[i] as num).toDouble(),
        weatherCode: codes[i] as int,
      ));
    }

    return forecasts;
  }

  static List<DailyForecast> _parseDaily(Map<String, dynamic> json) {
    final dates = json['time'] as List<dynamic>;
    final codes = json['weather_code'] as List<dynamic>;
    final maxTemps = json['temperature_2m_max'] as List<dynamic>;
    final minTemps = json['temperature_2m_min'] as List<dynamic>;

    final forecasts = <DailyForecast>[];
    for (var i = 0; i < dates.length; i++) {
      forecasts.add(DailyForecast(
        date: DateTime.parse(dates[i] as String),
        weatherCode: codes[i] as int,
        maxC: (maxTemps[i] as num).toDouble(),
        minC: (minTemps[i] as num).toDouble(),
      ));
    }

    return forecasts;
  }
}
