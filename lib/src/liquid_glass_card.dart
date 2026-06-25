import 'package:flutter/material.dart';

import 'liquid_glass_container.dart';
import 'liquid_glass_theme.dart';

/// A glass surface card: a [LiquidGlassContainer] with rounded clipping,
/// comfortable padding, and optional tap handling.
///
/// Use it to frame a block of Flutter content in native Liquid Glass without
/// wiring up the clip/padding boilerplate each time:
///
/// ```dart
/// LiquidGlassCard(
///   tint: Colors.indigo,
///   onTap: () {},
///   child: const Text('Tap me'),
/// )
/// ```
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.tint,
    this.borderRadius,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  /// Content rendered on top of the glass surface.
  final Widget child;

  /// Optional glass tint. Falls back to the [LiquidGlassTheme] tint.
  final Color? tint;

  /// Corner radius. Falls back to the [LiquidGlassTheme] value, otherwise 16.
  final double? borderRadius;

  /// Inner padding around [child].
  final EdgeInsetsGeometry padding;

  /// Optional tap handler. When non-null the whole card is tappable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double radius =
        borderRadius ?? LiquidGlassTheme.of(context).borderRadius ?? 16;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: LiquidGlassContainer(
        tint: tint,
        borderRadius: radius,
        onPressed: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
