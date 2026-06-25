class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxC,
    required this.minC,
  });

  final DateTime date;
  final int weatherCode;
  final double maxC;
  final double minC;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyForecast &&
          date == other.date &&
          weatherCode == other.weatherCode &&
          maxC == other.maxC &&
          minC == other.minC;

  @override
  int get hashCode => Object.hash(date, weatherCode, maxC, minC);
}
