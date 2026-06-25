/// Temperature unit for display.
enum TempUnit { celsius, fahrenheit }

/// Rounds a temperature value to the nearest integer.
int roundTemp(double celsius) => celsius.round();

/// Converts Celsius to Fahrenheit.
double celsiusToFahrenheit(double celsius) => celsius * 9 / 5 + 32;

/// Formats a temperature value with unit suffix.
///
/// Rounds the Celsius value, converts to Fahrenheit if [unit] is fahrenheit.
/// Returns a compact string like "23°C" or "72°F".
String formatTemp(double celsius, TempUnit unit) {
  final int value = switch (unit) {
    TempUnit.celsius => roundTemp(celsius),
    TempUnit.fahrenheit => roundTemp(celsiusToFahrenheit(celsius)),
  };
  final String suffix = switch (unit) {
    TempUnit.celsius => '\u00B0C',
    TempUnit.fahrenheit => '\u00B0F',
  };
  return '$value$suffix';
}

/// Formats a [DateTime] to a compact hour label like "14:00" or "9:05".
String formatHour(DateTime time) {
  final String h = time.hour.toString();
  final String m = time.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

final List<String> _dayNames = [
  'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
];

/// Formats a [DateTime] to a short day label like "Mon".
String formatDay(DateTime date) {
  // DateTime.monday = 1, sunday = 7 → our list index 0-6
  return _dayNames[(date.weekday - 1) % 7];
}
