import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'glass_style.dart';

/// The core frosted-glass surface used by every Liquid Glass widget.
///
/// Pure Flutter: a [BackdropFilter] blurs whatever is painted behind it, then a
/// tinted gradient, a bright rim, and a soft shadow fake the glass sheen. Works
/// on every platform Flutter supports.
class GlassBox extends StatelessWidget {
  const GlassBox({
    super.key,
    required this.style,
    required this.child,
  });

  final GlassStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(style.cornerRadius);
    final Color tint = style.effectiveTint;

    return DecoratedBox(
      // Soft drop shadow lifts the glass off the background.
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: style.blurSigma,
            sigmaY: style.blurSigma,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  tint.withValues(alpha: style.topOpacity),
                  tint.withValues(alpha: style.bottomOpacity),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.40),
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
