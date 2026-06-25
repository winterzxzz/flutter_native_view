import 'package:dio/dio.dart';

import '../models/geo_location_model.dart';
import '../models/forecast_model.dart';

class WeatherRemoteDataSource {
  WeatherRemoteDataSource({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  final Dio _dio;

  static const _geocodingBase = 'https://geocoding-api.open-meteo.com';
  static const _forecastBase = 'https://api.open-meteo.com';

  Future<GeoLocationModel> searchLocation(String query) async {
    final response = await _dio.get(
      '$_geocodingBase/v1/search',
      queryParameters: {
        'name': query,
        'count': 1,
        'language': 'en',
        'format': 'json',
      },
    );

    final data = response.data as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>?;

    if (results == null || results.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'No results found',
      );
    }

    return GeoLocationModel.fromJson(results[0] as Map<String, dynamic>);
  }

  Future<ForecastModel> fetchForecast({
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    final response = await _dio.get(
      '$_forecastBase/v1/forecast',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'timezone': timezone,
        'current':
            'temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code,is_day',
        'hourly': 'temperature_2m,weather_code',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
      },
    );

    final data = response.data as Map<String, dynamic>;
    return ForecastModel.fromJson(data);
  }
}
