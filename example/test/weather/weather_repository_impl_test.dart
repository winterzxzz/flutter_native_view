import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:liquid_glass_native_example/weather/data/datasources/weather_remote_data_source.dart';
import 'package:liquid_glass_native_example/weather/data/models/geo_location_model.dart';
import 'package:liquid_glass_native_example/weather/data/models/forecast_model.dart';
import 'package:liquid_glass_native_example/weather/data/repositories/weather_repository_impl.dart';
import 'package:liquid_glass_native_example/weather/domain/failures.dart';
import 'package:liquid_glass_native_example/weather/domain/entities/current_weather.dart';
import 'package:liquid_glass_native_example/weather/domain/entities/location.dart';

class MockRemoteDataSource extends Mock implements WeatherRemoteDataSource {}

void main() {
  late WeatherRepositoryImpl repository;
  late MockRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockRemoteDataSource();
    repository = WeatherRepositoryImpl(dataSource: mockDataSource);
  });

  group('search', () {
    test('returns Location on successful geocoding', () async {
      final model = GeoLocationModel(
        name: 'London',
        country: 'United Kingdom',
        admin1: 'England',
        latitude: 51.5,
        longitude: -0.1,
        timezone: 'Europe/London',
      );

      when(() => mockDataSource.searchLocation(any()))
          .thenAnswer((_) async => model);

      final result = await repository.search('London');

      expect(result.isRight(), true);
      final location = result.getOrElse(() => throw 'unreachable');
      expect(location.name, 'London');
      expect(location.latitude, 51.5);
    });

    test('returns NotFoundFailure on DioException with 200 (empty results)',
        () async {
      when(() => mockDataSource.searchLocation(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: {'results': []},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repository.search('Nowhereville');

      expect(result.isLeft(), true);
      expect(result, left(const NotFoundFailure()));
    });

    test('returns NetworkFailure on connection timeout', () async {
      when(() => mockDataSource.searchLocation(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await repository.search('London');

      expect(result.isLeft(), true);
      expect(result, left(const NetworkFailure()));
    });

    test('returns UnknownFailure on generic exception', () async {
      when(() => mockDataSource.searchLocation(any()))
          .thenThrow(Exception('unexpected'));

      final result = await repository.search('London');

      expect(result.isLeft(), true);
      expect(result, left(const UnknownFailure()));
    });
  });

  group('getForecast', () {
    final location = Location(
      name: 'London',
      country: 'United Kingdom',
      admin1: 'England',
      latitude: 51.5,
      longitude: -0.1,
      timezone: 'Europe/London',
    );

    test('returns WeatherBundle on successful forecast', () async {
      final model = ForecastModel(
        current: const CurrentWeather(
          tempC: 22.5,
          feelsLikeC: 20.1,
          humidity: 65.0,
          windKph: 12.3,
          weatherCode: 2,
          isDay: true,
        ),
        hourly: [],
        daily: [],
      );

      when(() => mockDataSource.fetchForecast(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            timezone: any(named: 'timezone'),
          )).thenAnswer((_) async => model);

      final result = await repository.getForecast(location);

      expect(result.isRight(), true);
      final bundle = result.getOrElse(() => throw 'unreachable');
      expect(bundle.location.name, 'London');
      expect(bundle.current.tempC, 22.5);
    });

    test('returns NetworkFailure on 5xx error', () async {
      when(() => mockDataSource.fetchForecast(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            timezone: any(named: 'timezone'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 502,
            data: {},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repository.getForecast(location);

      expect(result.isLeft(), true);
      expect(result, left(const NetworkFailure()));
    });

    test('returns UnknownFailure on parse error', () async {
      when(() => mockDataSource.fetchForecast(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            timezone: any(named: 'timezone'),
          )).thenThrow(
        const FormatException('bad json'),
      );

      final result = await repository.getForecast(location);

      expect(result.isLeft(), true);
      expect(result, left(const UnknownFailure()));
    });
  });
}
