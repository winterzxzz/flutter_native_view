import 'package:flutter/widgets.dart';

import 'glass_style.dart';
import 'liquid_glass.dart';

/// A tappable Liquid Glass button.
///
/// The glass is a decorative native surface; the tap is handled by Flutter, so
/// any [child] widget works as the label.
class LiquidGlassButton extends StatelessWidget {
  const LiquidGlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.style = const GlassStyle(),
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });

  /// A larger, more prominent variant suited to headings / hero actions.
  factory LiquidGlassButton.heading({
    Key? key,
    required Widget child,
    required VoidCallback onPressed,
    GlassStyle style = const GlassStyle(cornerRadius: 28),
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
  }) {
    return LiquidGlassButton(
      key: key,
      onPressed: onPressed,
      style: style,
      padding: padding,
      child: child,
    );
  }

  final Widget child;
  final VoidCallback onPressed;
  final GlassStyle style;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: LiquidGlass(style: style, padding: padding, child: child),
    );
  }
}
