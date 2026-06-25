import 'dart:ui' show Color, Gradient, Offset;

/// Visual representation of a weather condition.
///
/// Contains the gradient, SF Symbol icon name, and human-readable label
/// for a given WMO weather code and day/night state.
class WeatherVisual {
  /// Human-readable label e.g. "Clear", "Rain", "Snow".
  final String label;

  /// Gradient colors for the full-screen backdrop.
  final Gradient gradient;

  /// SF Symbol name for the condition icon.
  final String sfSymbol;

  const WeatherVisual({
    required this.label,
    required this.gradient,
    required this.sfSymbol,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherVisual &&
          label == other.label &&
          gradient == other.gradient &&
          sfSymbol == other.sfSymbol;

  @override
  int get hashCode => Object.hash(label, gradient, sfSymbol);
}

/// Creates a [Gradient.linear] from top center to bottom center with [colors].
Gradient _gradient(List<Color> colors) => Gradient.linear(
      const Offset(0, 0),
      const Offset(0, 1),
      colors,
    );

/// Day-time weather visuals keyed by WMO condition group.
final _dayVisuals = <String, WeatherVisual>{
  'clear': WeatherVisual(
    label: 'Clear',
    gradient: _gradient([const Color(0xFF2E8BFF), const Color(0xFF6FB8FF)]),
    sfSymbol: 'sun.max',
  ),
  'cloudy': WeatherVisual(
    label: 'Cloudy',
    gradient: _gradient([const Color(0xFF5B7A99), const Color(0xFF93A9C0)]),
    sfSymbol: 'cloud',
  ),
  'fog': WeatherVisual(
    label: 'Fog',
    gradient: _gradient([const Color(0xFF9BA4B5), const Color(0xFFC8CFD9)]),
    sfSymbol: 'cloud.fog',
  ),
  'drizzle': WeatherVisual(
    label: 'Drizzle',
    gradient: _gradient([const Color(0xFF7FA1C3), const Color(0xFFA8C5E0)]),
    sfSymbol: 'cloud.drizzle',
  ),
  'rain': WeatherVisual(
    label: 'Rain',
    gradient: _gradient([const Color(0xFF4A6D8E), const Color(0xFF7FA1C3)]),
    sfSymbol: 'cloud.rain',
  ),
  'snow': WeatherVisual(
    label: 'Snow',
    gradient: _gradient([const Color(0xFFD4E1F0), const Color(0xFFFFFFFF)]),
    sfSymbol: 'cloud.snow',
  ),
  'showers': WeatherVisual(
    label: 'Rain Showers',
    gradient: _gradient([const Color(0xFF3D5A73), const Color(0xFF6B8FA3)]),
    sfSymbol: 'cloud.heavyrain',
  ),
  'thunderstorm': WeatherVisual(
    label: 'Thunderstorm',
    gradient: _gradient([const Color(0xFF2C3E50), const Color(0xFF5D6D7E)]),
    sfSymbol: 'cloud.bolt.rain',
  ),
};

/// Night-time weather visuals (darker gradients).
final _nightVisuals = <String, WeatherVisual>{
  'clear': WeatherVisual(
    label: 'Clear',
    gradient: _gradient([const Color(0xFF0A0E27), const Color(0xFF1B2A6B)]),
    sfSymbol: 'moon.stars',
  ),
  'cloudy': WeatherVisual(
    label: 'Cloudy',
    gradient: _gradient([const Color(0xFF1A2332), const Color(0xFF3A4A5E)]),
    sfSymbol: 'cloud.moon',
  ),
  'fog': WeatherVisual(
    label: 'Fog',
    gradient: _gradient([const Color(0xFF2D3748), const Color(0xFF4A5568)]),
    sfSymbol: 'cloud.fog',
  ),
  'drizzle': WeatherVisual(
    label: 'Drizzle',
    gradient: _gradient([const Color(0xFF1E3A5F), const Color(0xFF2D5A8A)]),
    sfSymbol: 'cloud.drizzle',
  ),
  'rain': WeatherVisual(
    label: 'Rain',
    gradient: _gradient([const Color(0xFF0F283A), const Color(0xFF1E3A5F)]),
    sfSymbol: 'cloud.rain',
  ),
  'snow': WeatherVisual(
    label: 'Snow',
    gradient: _gradient([const Color(0xFF4A5B6E), const Color(0xFF8BA0B8)]),
    sfSymbol: 'cloud.snow',
  ),
  'showers': WeatherVisual(
    label: 'Rain Showers',
    gradient: _gradient([const Color(0xFF0D1B2A), const Color(0xFF1B3A4F)]),
    sfSymbol: 'cloud.heavyrain',
  ),
  'thunderstorm': WeatherVisual(
    label: 'Thunderstorm',
    gradient: _gradient([const Color(0xFF0A0E17), const Color(0xFF1A1F2E)]),
    sfSymbol: 'cloud.bolt.rain',
  ),
};

/// Maps a WMO weather code to its condition group key.
String _groupKey(int wmoCode) => switch (wmoCode) {
  0 || 1 => 'clear',
  2 || 3 => 'cloudy',
  45 || 48 => 'fog',
  51 || 53 || 55 || 56 || 57 => 'drizzle',
  61 || 63 || 65 || 66 || 67 => 'rain',
  71 || 73 || 75 || 77 => 'snow',
  80 || 81 || 82 => 'showers',
  85 || 86 => 'snow',
  95 || 96 || 99 => 'thunderstorm',
  _ => 'clear',
};

/// Returns a [WeatherVisual] for the given WMO [wmoCode] and day/night state.
WeatherVisual weatherVisualFromCode(int wmoCode, bool isDay) {
  final key = _groupKey(wmoCode);
  return isDay ? _dayVisuals[key]! : _nightVisuals[key]!;
}
