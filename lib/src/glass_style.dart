import 'package:flutter/widgets.dart';

/// Visual variant of the Liquid Glass material.
///
/// Maps to Apple's `Glass` styles on iOS 26+.
enum GlassVariant {
  /// Frosted glass that adapts to the content behind it. Default.
  regular,

  /// Highly translucent glass with minimal frosting.
  clear,
}

/// Immutable style description for a Liquid Glass surface.
///
/// Passed across the platform channel to the native SwiftUI layer.
@immutable
class GlassStyle {
  const GlassStyle({
    this.tint,
    this.cornerRadius = 20,
    this.variant = GlassVariant.regular,
  });

  /// Optional color tint applied to the glass. `null` keeps the neutral glass.
  final Color? tint;

  /// Corner radius of the rounded glass shape, in logical pixels.
  final double cornerRadius;

  /// Frosting variant. See [GlassVariant].
  final GlassVariant variant;

  GlassStyle copyWith({
    Color? tint,
    double? cornerRadius,
    GlassVariant? variant,
  }) {
    return GlassStyle(
      tint: tint ?? this.tint,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      variant: variant ?? this.variant,
    );
  }

  /// Serializes to the map consumed by the native platform view factory.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tintColor': tint?.toARGB32(),
      'cornerRadius': cornerRadius,
      'variant': variant.name,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is GlassStyle &&
        other.tint == tint &&
        other.cornerRadius == cornerRadius &&
        other.variant == variant;
  }

  @override
  int get hashCode => Object.hash(tint, cornerRadius, variant);
}
