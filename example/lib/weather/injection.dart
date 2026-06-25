import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'data/datasources/weather_remote_data_source.dart';
import 'data/repositories/weather_repository_impl.dart';
import 'domain/repositories/weather_repository.dart';
import 'presentation/cubit/weather_cubit.dart';
import 'presentation/cubit/settings_cubit.dart';
import 'presentation/cubit/tab_cubit.dart';

final getIt = GetIt.instance;

/// Registers all weather example dependencies.
///
/// Safe to call multiple times — guards against double-registration.
void configureWeatherDependencies() {
  if (getIt.isRegistered<WeatherRepository>()) return;

  // Data
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerSingleton<WeatherRemoteDataSource>(
    WeatherRemoteDataSource(dio: getIt<Dio>()),
  );
  getIt.registerSingleton<WeatherRepository>(
    WeatherRepositoryImpl(dataSource: getIt<WeatherRemoteDataSource>()),
  );

  // Cubits
  getIt.registerFactory<WeatherCubit>(
    () => WeatherCubit(getIt<WeatherRepository>()),
  );
  getIt.registerFactory<SettingsCubit>(() => SettingsCubit());
  getIt.registerFactory<TabCubit>(() => TabCubit());
}
