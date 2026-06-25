import 'package:dartz/dartz.dart';

import '../failures.dart';
import '../entities/location.dart';
import '../entities/weather_bundle.dart';

abstract class WeatherRepository {
  Future<Either<Failure, Location>> search(String query);

  Future<Either<Failure, WeatherBundle>> getForecast(Location location);
}
