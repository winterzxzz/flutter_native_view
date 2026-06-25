import 'location.dart';
import 'current_weather.dart';
import 'hourly_forecast.dart';
import 'daily_forecast.dart';

class WeatherBundle {
  const WeatherBundle({
    required this.location,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  final Location location;
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherBundle &&
          location == other.location &&
          current == other.current &&
          _listEq(hourly, other.hourly) &&
          _listEq(daily, other.daily);

  @override
  int get hashCode => Object.hash(
        location,
        current,
        Object.hashAll(hourly),
        Object.hashAll(daily),
      );

  static bool _listEq<T>(List<T> a, List<T> b) =>
      a.length == b.length &&
      a.asMap().entries.every((e) => e.value == b[e.key]);
}
