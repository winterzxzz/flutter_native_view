import '../../domain/entities/weather_bundle.dart';

/// Sealed state for the weather search/forecast flow.
sealed class WeatherState {
  const WeatherState();
}

/// Initial state before any search.
class WeatherInitial extends WeatherState {
  const WeatherInitial();

  @override
  bool operator ==(Object other) => other is WeatherInitial;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Loading state during search or forecast fetch.
class WeatherLoading extends WeatherState {
  const WeatherLoading();

  @override
  bool operator ==(Object other) => other is WeatherLoading;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Successful forecast loaded.
class WeatherLoaded extends WeatherState {
  const WeatherLoaded(this.bundle);

  final WeatherBundle bundle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherLoaded && bundle == other.bundle;

  @override
  int get hashCode => bundle.hashCode;
}

/// Error state with a user-readable message.
class WeatherError extends WeatherState {
  const WeatherError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherError && message == other.message;

  @override
  int get hashCode => message.hashCode;
}
