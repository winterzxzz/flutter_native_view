import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:liquid_glass_native_example/weather/domain/failures.dart';
import 'package:liquid_glass_native_example/weather/domain/entities/location.dart';
import 'package:liquid_glass_native_example/weather/domain/entities/current_weather.dart';
import 'package:liquid_glass_native_example/weather/domain/entities/hourly_forecast.dart';
import 'package:liquid_glass_native_example/weather/domain/entities/daily_forecast.dart';
import 'package:liquid_glass_native_example/weather/domain/entities/weather_bundle.dart';
import 'package:liquid_glass_native_example/weather/domain/repositories/weather_repository.dart';
import 'package:liquid_glass_native_example/weather/presentation/cubit/weather_cubit.dart';
import 'package:liquid_glass_native_example/weather/presentation/cubit/weather_state.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

WeatherBundle _testBundle(Location location) {
  return WeatherBundle(
    location: location,
    current: const CurrentWeather(
      tempC: 22,
      feelsLikeC: 20,
      humidity: 65,
      windKph: 12,
      weatherCode: 0,
      isDay: true,
    ),
    hourly: [
      HourlyForecast(
        time: DateTime(2026, 6, 25, 14),
        tempC: 22,
        weatherCode: 0,
      ),
    ],
    daily: [
      DailyForecast(
        date: DateTime(2026, 6, 25),
        weatherCode: 0,
        maxC: 25,
        minC: 18,
      ),
    ],
  );
}

void main() {
  late MockWeatherRepository repository;
  late Location testLocation;

  setUp(() {
    repository = MockWeatherRepository();
    testLocation = const Location(
      name: 'London',
      country: 'United Kingdom',
      admin1: 'England',
      latitude: 51.5,
      longitude: -0.13,
      timezone: 'Europe/London',
    );
  });

  group('WeatherCubit', () {
    blocTest<WeatherCubit, WeatherState>(
      'emits [WeatherLoading, WeatherLoaded] on successful search + forecast',
      setUp: () {
        when(() => repository.search('London'))
            .thenAnswer((_) async => Right(testLocation));
        when(() => repository.getForecast(testLocation))
            .thenAnswer((_) async => Right(_testBundle(testLocation)));
      },
      build: () => WeatherCubit(repository),
      act: (cubit) => cubit.search('London'),
      expect: () => [
        const WeatherLoading(),
        WeatherLoaded(_testBundle(testLocation)),
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'emits [WeatherLoading, WeatherError] when search fails with NotFound',
      setUp: () {
        when(() => repository.search(any()))
            .thenAnswer((_) async => Left(NotFoundFailure()));
      },
      build: () => WeatherCubit(repository),
      act: (cubit) => cubit.search('Atlantis'),
      expect: () => [
        const WeatherLoading(),
        const WeatherError('City not found. Try another name.'),
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'emits [WeatherLoading, WeatherError] when network fails',
      setUp: () {
        when(() => repository.search(any()))
            .thenAnswer((_) async => Left(NetworkFailure()));
      },
      build: () => WeatherCubit(repository),
      act: (cubit) => cubit.search('London'),
      expect: () => [
        const WeatherLoading(),
        const WeatherError("Can't reach weather service"),
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'emits [WeatherLoading, WeatherError] when forecast fails after search succeeds',
      setUp: () {
        when(() => repository.search('Paris'))
            .thenAnswer((_) async => Right(testLocation));
        when(() => repository.getForecast(testLocation))
            .thenAnswer((_) async => Left(UnknownFailure()));
      },
      build: () => WeatherCubit(repository),
      act: (cubit) => cubit.search('Paris'),
      expect: () => [
        const WeatherLoading(),
        const WeatherError('Something went wrong'),
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'retry re-runs the last query',
      setUp: () {
        when(() => repository.search('London'))
            .thenAnswer((_) async => Right(testLocation));
        when(() => repository.getForecast(testLocation))
            .thenAnswer((_) async => Right(_testBundle(testLocation)));
      },
      build: () => WeatherCubit(repository),
      act: (cubit) async {
        await cubit.search('London');
        await cubit.retry();
      },
      expect: () => [
        const WeatherLoading(),
        WeatherLoaded(_testBundle(testLocation)),
        const WeatherLoading(),
        WeatherLoaded(_testBundle(testLocation)),
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'retry is no-op when there was no prior query',
      build: () => WeatherCubit(repository),
      act: (cubit) => cubit.retry(),
      expect: () => [],
    );

    blocTest<WeatherCubit, WeatherState>(
      'retry after error re-attempts the query',
      setUp: () {
        when(() => repository.search('London'))
            .thenAnswer((_) async => Left(NetworkFailure()));
        when(() => repository.getForecast(testLocation))
            .thenAnswer((_) async => Right(_testBundle(testLocation)));
      },
      build: () => WeatherCubit(repository),
      act: (cubit) async {
        await cubit.search('London');
        // Second call succeeds
        when(() => repository.search('London'))
            .thenAnswer((_) async => Right(testLocation));
        await cubit.retry();
      },
      expect: () => [
        const WeatherLoading(),
        const WeatherError("Can't reach weather service"),
        const WeatherLoading(),
        WeatherLoaded(_testBundle(testLocation)),
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'initial state is WeatherInitial',
      build: () => WeatherCubit(repository),
      verify: (cubit) => expect(cubit.state, const WeatherInitial()),
    );
  });
}
