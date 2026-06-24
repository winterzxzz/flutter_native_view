import 'package:flutter/widgets.dart';

import 'glass_box.dart';
import 'glass_style.dart';

/// Wraps any [child] in a Liquid Glass surface.
///
/// The glass blurs and tints whatever is painted behind it, so place it over a
/// colorful background, image, or scrolling content for the best effect.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.style = const GlassStyle(),
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final GlassStyle style;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      style: style,
      child: Padding(padding: padding, child: child),
    );
  }
}
