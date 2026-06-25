class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.tempC,
    required this.weatherCode,
  });

  final DateTime time;
  final double tempC;
  final int weatherCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HourlyForecast &&
          time == other.time &&
          tempC == other.tempC &&
          weatherCode == other.weatherCode;

  @override
  int get hashCode => Object.hash(time, tempC, weatherCode);
}
