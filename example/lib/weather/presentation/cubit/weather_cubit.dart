import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

import '../../domain/failures.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/weather_bundle.dart';
import '../../domain/repositories/weather_repository.dart';
import 'weather_state.dart';

/// Cubit that manages the weather search → forecast flow.
class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit(this._repository) : super(const WeatherInitial());

  final WeatherRepository _repository;

  /// The last query string, used for Retry.
  String? _lastQuery;

  /// Searches for a city and loads its forecast.
  ///
  /// Emits [WeatherLoading] immediately, then either [WeatherLoaded] or
  /// [WeatherError] depending on the result.
  Future<void> search(String query) async {
    _lastQuery = query;
    emit(const WeatherLoading());

    final Either<Failure, Location> locationResult =
        await _repository.search(query);

    locationResult.fold(
      (Failure failure) => emit(WeatherError(failure.message)),
      (Location location) => _fetchForecast(location),
    );
  }

  /// Retries the last query, or no-op if there was none.
  Future<void> retry() async {
    final String? query = _lastQuery;
    if (query != null) {
      await search(query);
    }
  }

  Future<void> _fetchForecast(Location location) async {
    final Either<Failure, WeatherBundle> forecastResult =
        await _repository.getForecast(location);

    forecastResult.fold(
      (Failure failure) => emit(WeatherError(failure.message)),
      (WeatherBundle bundle) => emit(WeatherLoaded(bundle)),
    );
  }
}
