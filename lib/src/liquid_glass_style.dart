import 'package:flutter/material.dart';

/// The native Liquid Glass material variant.
enum LiquidGlassVariant {
  /// The standard adaptive Liquid Glass material.
  regular,

  /// A clearer material. Add sufficient tint or surrounding contrast to keep
  /// foreground content legible.
  clear,
}

/// A shape understood by both Flutter fallbacks and native SwiftUI glass.
@immutable
sealed class LiquidGlassShape {
  const LiquidGlassShape();

  /// The system's default capsule shape.
  const factory LiquidGlassShape.capsule() = LiquidGlassCapsuleShape;

  /// A circular shape, intended for square icon controls.
  const factory LiquidGlassShape.circle() = LiquidGlassCircleShape;

  /// A continuous rounded rectangle.
  const factory LiquidGlassShape.roundedRectangle({
    required double cornerRadius,
  }) = LiquidGlassRoundedRectangleShape;
}

/// A capsule-shaped glass surface.
@immutable
final class LiquidGlassCapsuleShape extends LiquidGlassShape {
  const LiquidGlassCapsuleShape();

  @override
  bool operator ==(Object other) => other is LiquidGlassCapsuleShape;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// A circular glass surface.
@immutable
final class LiquidGlassCircleShape extends LiquidGlassShape {
  const LiquidGlassCircleShape();

  @override
  bool operator ==(Object other) => other is LiquidGlassCircleShape;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// A continuous rounded-rectangle glass surface.
@immutable
final class LiquidGlassRoundedRectangleShape extends LiquidGlassShape {
  const LiquidGlassRoundedRectangleShape({required this.cornerRadius})
    : assert(cornerRadius >= 0 && cornerRadius < double.infinity);

  /// The corner radius in logical points.
  final double cornerRadius;

  @override
  bool operator ==(Object other) =>
      other is LiquidGlassRoundedRectangleShape &&
      other.cornerRadius == cornerRadius;

  @override
  int get hashCode => Object.hash(runtimeType, cornerRadius);
}

/// Immutable material configuration for controls that own custom glass.
@immutable
final class LiquidGlassStyle {
  const LiquidGlassStyle({
    this.variant = LiquidGlassVariant.regular,
    this.tint,
    this.shape = const LiquidGlassShape.capsule(),
    this.interactive = true,
  });

  /// The native glass material variant.
  final LiquidGlassVariant variant;

  /// Optional material tint. This never doubles as a foreground color.
  final Color? tint;

  /// Shape used by custom glass and glass buttons that support custom shapes.
  final LiquidGlassShape shape;

  /// Whether custom glass reacts to touch. Reduce Motion can suppress this.
  final bool interactive;

  /// Derives a local style variation.
  ///
  /// Use [withoutTint] when the derived style must explicitly remove a tint.
  LiquidGlassStyle copyWith({
    LiquidGlassVariant? variant,
    Color? tint,
    LiquidGlassShape? shape,
    bool? interactive,
  }) {
    return LiquidGlassStyle(
      variant: variant ?? this.variant,
      tint: tint ?? this.tint,
      shape: shape ?? this.shape,
      interactive: interactive ?? this.interactive,
    );
  }

  /// Returns the same style without a material tint.
  LiquidGlassStyle withoutTint() => LiquidGlassStyle(
    variant: variant,
    shape: shape,
    interactive: interactive,
  );

  @override
  bool operator ==(Object other) =>
      other is LiquidGlassStyle &&
      other.variant == variant &&
      other.tint == tint &&
      other.shape == shape &&
      other.interactive == interactive;

  @override
  int get hashCode => Object.hash(variant, tint, shape, interactive);
}

/// Semantic native control sizing, rather than arbitrary per-widget numbers.
enum LiquidGlassControlSize {
  compact,
  regular,
  large;

  /// A conservative Flutter-side estimate used until native measurement.
  double get minimumDimension => switch (this) {
    compact => 36,
    regular => 44,
    large => 52,
  };
}

/// Shared appearance configuration for native and Material controls.
@immutable
final class LiquidGlassControlStyle {
  const LiquidGlassControlStyle({
    this.tintColor,
    this.foregroundColor,
    this.brightness,
    this.size = LiquidGlassControlSize.regular,
    this.disabledOpacity = 0.45,
  }) : assert(disabledOpacity >= 0 && disabledOpacity <= 1);

  /// System accent for standard controls such as switches and sliders.
  final Color? tintColor;

  /// Native foreground color for labels and SF Symbols.
  final Color? foregroundColor;

  /// Optional forced native light/dark appearance. Null follows the system.
  final Brightness? brightness;

  /// Semantic control size shared by native and fallback controls.
  final LiquidGlassControlSize size;

  /// Opacity used for disabled custom controls.
  final double disabledOpacity;

  /// Derives a local control-style variation.
  ///
  /// The `clear...` flags distinguish removing a nullable value from omitting
  /// that parameter and retaining its current value.
  LiquidGlassControlStyle copyWith({
    Color? tintColor,
    Color? foregroundColor,
    Brightness? brightness,
    LiquidGlassControlSize? size,
    double? disabledOpacity,
    bool clearTintColor = false,
    bool clearForegroundColor = false,
    bool clearBrightness = false,
  }) {
    assert(!clearTintColor || tintColor == null);
    assert(!clearForegroundColor || foregroundColor == null);
    assert(!clearBrightness || brightness == null);
    return LiquidGlassControlStyle(
      tintColor: clearTintColor ? null : tintColor ?? this.tintColor,
      foregroundColor: clearForegroundColor
          ? null
          : foregroundColor ?? this.foregroundColor,
      brightness: clearBrightness ? null : brightness ?? this.brightness,
      size: size ?? this.size,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LiquidGlassControlStyle &&
      other.tintColor == tintColor &&
      other.foregroundColor == foregroundColor &&
      other.brightness == brightness &&
      other.size == size &&
      other.disabledOpacity == disabledOpacity;

  @override
  int get hashCode => Object.hash(
    tintColor,
    foregroundColor,
    brightness,
    size,
    disabledOpacity,
  );
}

/// An SF Symbol paired with a Flutter icon for non-iOS fallbacks.
@immutable
final class LiquidGlassSymbol {
  const LiquidGlassSymbol(this.name, {this.fallbackIcon})
    : assert(name.length > 0);

  /// SF Symbol name used by SwiftUI, for example `heart.fill`.
  final String name;

  /// Material icon used by non-iOS fallbacks.
  final IconData? fallbackIcon;

  @override
  bool operator ==(Object other) =>
      other is LiquidGlassSymbol &&
      other.name == name &&
      other.fallbackIcon == fallbackIcon;

  @override
  int get hashCode => Object.hash(name, fallbackIcon);
}
