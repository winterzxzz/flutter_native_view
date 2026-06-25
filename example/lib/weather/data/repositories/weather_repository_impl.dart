import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../domain/failures.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/weather_bundle.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_data_source.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl({WeatherRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? WeatherRemoteDataSource();

  final WeatherRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, Location>> search(String query) async {
    try {
      final model = await _dataSource.searchLocation(query);
      return right(model.toEntity());
    } on DioException catch (e) {
      return left(_mapDioError(e, isGeocoding: true));
    } catch (_) {
      return left(const UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, WeatherBundle>> getForecast(
      Location location) async {
    try {
      final model = await _dataSource.fetchForecast(
        latitude: location.latitude,
        longitude: location.longitude,
        timezone: location.timezone,
      );
      return right(model.toEntity(location));
    } on DioException catch (e) {
      return left(_mapDioError(e, isGeocoding: false));
    } catch (_) {
      return left(const UnknownFailure());
    }
  }

  Failure _mapDioError(DioException e, {required bool isGeocoding}) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      if (statusCode == 404 || (isGeocoding && statusCode == 200)) {
        return const NotFoundFailure();
      }
      if (statusCode != null && statusCode >= 500) {
        return const NetworkFailure();
      }
    }

    return const UnknownFailure();
  }
}
