import 'package:flutter/material.dart';

/// User-selectable appearance for the weather app. Drives the backdrop so it
/// stays stable across searches instead of flipping with the weather code.
enum AppThemeMode { light, dark }

/// Fixed backdrop gradient for the given [mode].
LinearGradient appThemeGradient(AppThemeMode mode) {
  final colors = switch (mode) {
    AppThemeMode.light => const [Color(0xFF2E8BFF), Color(0xFF6FB8FF)],
    AppThemeMode.dark => const [Color(0xFF0A0E27), Color(0xFF1B2A6B)],
  };
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: colors,
  );
}
