import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'liquid_glass_theme.dart';

const String _kContainerViewType = 'flutter_native_view/glass_container';

/// A decorative glass panel rendered natively on iOS.
///
/// Provides a Liquid Glass surface that can wrap Flutter content. On iOS 26+
/// it renders authentic Apple glass; on older iOS it uses standard SwiftUI
/// styling; on non-iOS platforms it falls back to a Material [DecoratedBox].
///
/// Provide a [child] to render Flutter content layered on top of the glass
/// surface:
/// ```dart
/// LiquidGlassContainer(
///   child: Padding(
///     padding: EdgeInsets.all(16),
///     child: Text('Content'),
///   ),
/// )
/// ```
class LiquidGlassContainer extends StatefulWidget {
  const LiquidGlassContainer({
    super.key,
    this.tint,
    this.borderRadius,
    this.child,
  });

  /// Optional glass tint color.
  final Color? tint;

  /// Corner radius. When `null`, uses a continuous rounded rectangle with
  /// a default radius of 20.
  final double? borderRadius;

  /// Optional Flutter content rendered on top of the glass surface. The glass
  /// sizes itself to the child; when `null` it expands to fill its parent.
  final Widget? child;

  @override
  State<LiquidGlassContainer> createState() => _LiquidGlassContainerState();
}

class _LiquidGlassContainerState extends State<LiquidGlassContainer> {
  Map<String, dynamic> _params() {
    final LiquidGlassThemeData t = LiquidGlassTheme.of(context);
    return <String, dynamic>{
      'tint': (widget.tint ?? t.tint)?.toARGB32(),
      'cornerRadius': widget.borderRadius ?? t.borderRadius,
      'respectAccessibility': t.respectAccessibility,
    };
  }

  @override
  Widget build(BuildContext context) {
    final LiquidGlassThemeData t = LiquidGlassTheme.of(context);
    final Color? tint = widget.tint ?? t.tint;
    final double radius = widget.borderRadius ?? t.borderRadius ?? 20;
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: tint?.withValues(alpha: 0.15) ?? Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: tint?.withValues(alpha: 0.30) ?? Colors.white.withValues(alpha: 0.22),
          ),
        ),
        child: widget.child ?? const SizedBox.expand(),
      );
    }

    final Widget glass = UiKitView(
      viewType: _kContainerViewType,
      creationParams: _params(),
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (int id) {},
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
    );

    if (widget.child == null) return glass;

    // Size the glass to the child and layer the content on top.
    return Stack(
      children: <Widget>[
        Positioned.fill(child: glass),
        widget.child!,
      ],
    );
  }
}
