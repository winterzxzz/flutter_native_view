import 'package:flutter/widgets.dart';

import 'glass_style.dart';
import 'liquid_glass.dart';

/// A tappable Liquid Glass button.
///
/// The glass is a decorative native surface; the tap and the press feedback are
/// handled by Flutter, so any [child] widget works as the label.
class LiquidGlassButton extends StatefulWidget {
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
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        widget.onPressed();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Stack(
          children: <Widget>[
            LiquidGlass(
              style: widget.style,
              padding: widget.padding,
              child: widget.child,
            ),
            // Pure-Flutter press highlight: reliable even over the native
            // glass platform view, where Flutter opacity is not honored.
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _pressed ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 120),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0x26FFFFFF),
                      borderRadius:
                          BorderRadius.circular(widget.style.cornerRadius),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
