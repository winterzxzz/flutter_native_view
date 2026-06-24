import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String _kContainerViewType = 'flutter_native_view/glass_container';

/// A decorative glass panel rendered natively on iOS.
///
/// Provides a Liquid Glass surface that can wrap Flutter content. On iOS 26+
/// it renders authentic Apple glass; on older iOS it uses standard SwiftUI
/// styling; on non-iOS platforms it falls back to a Material [DecoratedBox].
///
/// Place content on top by wrapping both in a [Stack]:
/// ```dart
/// Stack(
///   children: [
///     const LiquidGlassContainer(),
///     Padding(
///       padding: EdgeInsets.all(16),
///       child: Text('Content'),
///     ),
///   ],
/// )
/// ```
class LiquidGlassContainer extends StatefulWidget {
  const LiquidGlassContainer({
    super.key,
    this.tint,
    this.borderRadius,
  });

  /// Optional glass tint color.
  final Color? tint;

  /// Corner radius. When `null`, uses a continuous rounded rectangle with
  /// a default radius of 20.
  final double? borderRadius;

  @override
  State<LiquidGlassContainer> createState() => _LiquidGlassContainerState();
}

class _LiquidGlassContainerState extends State<LiquidGlassContainer> {
  Map<String, dynamic> _params() => <String, dynamic>{
        'tint': widget.tint?.toARGB32(),
        'cornerRadius': widget.borderRadius,
      };

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: widget.tint?.withValues(alpha: 0.15) ?? Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 20),
          border: Border.all(
            color: widget.tint?.withValues(alpha: 0.30) ?? Colors.white.withValues(alpha: 0.22),
          ),
        ),
        child: const SizedBox.expand(),
      );
    }

    return UiKitView(
      viewType: _kContainerViewType,
      creationParams: _params(),
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (int id) {},
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
    );
  }
}
