import 'package:flutter/widgets.dart';

import 'liquid_glass_diagnostics.dart';
import 'liquid_glass_style.dart';

/// Immutable subtree defaults for custom glass surfaces and system controls.
@immutable
final class LiquidGlassThemeData {
  const LiquidGlassThemeData({
    this.style = const LiquidGlassStyle(),
    this.controlStyle = const LiquidGlassControlStyle(),
  });

  /// Default custom glass material configuration.
  final LiquidGlassStyle style;

  /// Default native/Material control configuration.
  final LiquidGlassControlStyle controlStyle;

  LiquidGlassThemeData copyWith({
    LiquidGlassStyle? style,
    LiquidGlassControlStyle? controlStyle,
  }) {
    return LiquidGlassThemeData(
      style: style ?? this.style,
      controlStyle: controlStyle ?? this.controlStyle,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LiquidGlassThemeData &&
      other.style == style &&
      other.controlStyle == controlStyle;

  @override
  int get hashCode => Object.hash(style, controlStyle);
}

/// Supplies live style defaults and optional diagnostics to descendant controls.
///
/// Existing native views are synchronized when [data] changes; they are not
/// recreated.
class LiquidGlassTheme extends InheritedTheme {
  const LiquidGlassTheme({
    super.key,
    required this.data,
    this.diagnostics,
    required super.child,
  });

  final LiquidGlassThemeData data;

  /// Optional payload-free method-channel instrumentation.
  final LiquidGlassDiagnostics? diagnostics;

  static const LiquidGlassThemeData _default = LiquidGlassThemeData();

  /// The nearest theme data, or stable built-in defaults.
  static LiquidGlassThemeData of(BuildContext context) {
    return maybeOf(context)?.data ?? _default;
  }

  /// The nearest theme wrapper, if one exists.
  static LiquidGlassTheme? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LiquidGlassTheme>();
  }

  @override
  bool updateShouldNotify(LiquidGlassTheme oldWidget) =>
      data != oldWidget.data || diagnostics != oldWidget.diagnostics;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return LiquidGlassTheme(data: data, diagnostics: diagnostics, child: child);
  }
}
