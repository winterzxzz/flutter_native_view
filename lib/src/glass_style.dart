import 'package:flutter/widgets.dart';

/// Visual variant of the Liquid Glass material.
enum GlassVariant {
  /// Frosted glass with a visible tint. Default.
  regular,

  /// Highly translucent glass with minimal tint.
  clear,
}

/// Immutable style description for a Liquid Glass surface.
@immutable
class GlassStyle {
  const GlassStyle({
    this.tint,
    this.cornerRadius = 20,
    this.variant = GlassVariant.regular,
    this.blurSigma = 18,
  });

  /// Color tint of the glass. Defaults to white when `null`.
  final Color? tint;

  /// Corner radius of the rounded glass shape, in logical pixels.
  final double cornerRadius;

  /// Frosting variant. See [GlassVariant].
  final GlassVariant variant;

  /// Gaussian blur strength applied to the content behind the glass.
  final double blurSigma;

  /// Opacity multiplier for the tint overlay (lower for [GlassVariant.clear]).
  double get _tintStrength => variant == GlassVariant.clear ? 0.45 : 1.0;

  /// Effective tint color, falling back to white.
  Color get effectiveTint => tint ?? const Color(0xFFFFFFFF);

  /// Top/bottom overlay opacities used to fake the glass sheen.
  double get topOpacity => 0.28 * _tintStrength;
  double get bottomOpacity => 0.10 * _tintStrength;

  GlassStyle copyWith({
    Color? tint,
    double? cornerRadius,
    GlassVariant? variant,
    double? blurSigma,
  }) {
    return GlassStyle(
      tint: tint ?? this.tint,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      variant: variant ?? this.variant,
      blurSigma: blurSigma ?? this.blurSigma,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GlassStyle &&
        other.tint == tint &&
        other.cornerRadius == cornerRadius &&
        other.variant == variant &&
        other.blurSigma == blurSigma;
  }

  @override
  int get hashCode => Object.hash(tint, cornerRadius, variant, blurSigma);
}
