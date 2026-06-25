class CurrentWeather {
  const CurrentWeather({
    required this.tempC,
    required this.feelsLikeC,
    required this.humidity,
    required this.windKph,
    required this.weatherCode,
    required this.isDay,
  });

  final double tempC;
  final double feelsLikeC;
  final double humidity;
  final double windKph;
  final int weatherCode;
  final bool isDay;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentWeather &&
          tempC == other.tempC &&
          feelsLikeC == other.feelsLikeC &&
          humidity == other.humidity &&
          windKph == other.windKph &&
          weatherCode == other.weatherCode &&
          isDay == other.isDay;

  @override
  int get hashCode =>
      Object.hash(tempC, feelsLikeC, humidity, windKph, weatherCode, isDay);
}
