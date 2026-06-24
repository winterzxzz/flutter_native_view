import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'glass_style.dart';
import 'platform/glass_surface_view.dart';

/// Wraps any [child] in a native Liquid Glass surface.
///
/// On iOS 26+ the glass is rendered by SwiftUI behind the child. On other
/// platforms (or iOS &lt; 26 in release) a plain tinted fallback is shown so
/// layouts never break.
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
    assert(
      defaultTargetPlatform == TargetPlatform.iOS,
      'LiquidGlass renders native glass on iOS 26+ only. '
      'Other platforms show a plain fallback container.',
    );

    final Widget content = Padding(padding: padding, child: child);

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return FallbackGlass(style: style, child: content);
    }

    return Stack(
      children: <Widget>[
        Positioned.fill(child: GlassSurfaceView(style: style)),
        content,
      ],
    );
  }
}

/// Pure-Flutter approximation used off iOS. Keeps layout intact, no native glass.
class FallbackGlass extends StatelessWidget {
  const FallbackGlass({super.key, required this.style, required this.child});

  final GlassStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Color base = style.tint ?? const Color(0xFFFFFFFF);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(style.cornerRadius),
        border: Border.all(color: base.withValues(alpha: 0.25)),
      ),
      child: child,
    );
  }
}
