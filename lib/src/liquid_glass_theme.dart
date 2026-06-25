import 'package:flutter/widgets.dart';

/// Default styling for all `liquid_glass_native` widgets in a subtree.
///
/// Carried by [LiquidGlassTheme]. Each widget resolves a value as
/// **explicit parameter ?? theme value ?? built-in default**, so a theme only
/// fills in what a call site leaves unset and existing code keeps working
/// unchanged.
@immutable
class LiquidGlassThemeData {
  const LiquidGlassThemeData({
    this.tint,
    this.borderRadius,
    this.interactive,
    this.labelColor,
    this.respectAccessibility = true,
  });

  /// Default glass tint color.
  final Color? tint;

  /// Default corner radius for glass surfaces.
  final double? borderRadius;

  /// Default for whether iOS 26 glass reacts to touch.
  final bool? interactive;

  /// Default label/foreground color for native text.
  final Color? labelColor;

  /// When `true` (default), native glass honors the system accessibility
  /// settings *Reduce Transparency* (renders a solid fill) and *Reduce Motion*
  /// (drops the interactive touch response).
  final bool respectAccessibility;

  /// Returns a copy with the given fields replaced.
  LiquidGlassThemeData copyWith({
    Color? tint,
    double? borderRadius,
    bool? interactive,
    Color? labelColor,
    bool? respectAccessibility,
  }) {
    return LiquidGlassThemeData(
      tint: tint ?? this.tint,
      borderRadius: borderRadius ?? this.borderRadius,
      interactive: interactive ?? this.interactive,
      labelColor: labelColor ?? this.labelColor,
      respectAccessibility: respectAccessibility ?? this.respectAccessibility,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LiquidGlassThemeData &&
      other.tint == tint &&
      other.borderRadius == borderRadius &&
      other.interactive == interactive &&
      other.labelColor == labelColor &&
      other.respectAccessibility == respectAccessibility;

  @override
  int get hashCode =>
      Object.hash(tint, borderRadius, interactive, labelColor, respectAccessibility);
}

/// Supplies default [LiquidGlassThemeData] to descendant glass widgets.
///
/// Place it above your app (e.g. wrapping `MaterialApp.builder` or the home
/// widget) to set app-wide glass defaults:
///
/// ```dart
/// LiquidGlassTheme(
///   data: const LiquidGlassThemeData(
///     tint: Color(0xFF0A84FF),
///     borderRadius: 16,
///   ),
///   child: MyApp(),
/// )
/// ```
///
/// The theme is read when a widget is built. Changing it after a native view
/// has been created does not restyle the existing view.
class LiquidGlassTheme extends InheritedWidget {
  const LiquidGlassTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The styling defaults provided to descendants.
  final LiquidGlassThemeData data;

  static const LiquidGlassThemeData _default = LiquidGlassThemeData();

  /// The nearest theme data above [context], or a const default when none is
  /// present. Never returns `null`.
  static LiquidGlassThemeData of(BuildContext context) {
    final LiquidGlassTheme? theme =
        context.dependOnInheritedWidgetOfExactType<LiquidGlassTheme>();
    return theme?.data ?? _default;
  }

  @override
  bool updateShouldNotify(LiquidGlassTheme oldWidget) => data != oldWidget.data;
}
