import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'liquid_glass_theme.dart';

const String _kActivityIndicatorViewType = 'flutter_native_view/glass_activity_indicator';

/// A native SwiftUI activity indicator (spinner) with Liquid Glass styling on
/// iOS 26+.
///
/// On non-iOS platforms it falls back to a Material [CircularProgressIndicator].
class LiquidGlassActivityIndicator extends StatefulWidget {
  const LiquidGlassActivityIndicator({
    super.key,
    this.size = 24,
    this.tint,
  });

  /// The diameter of the indicator. Defaults to 24.
  final double size;

  /// Optional tint color.
  final Color? tint;

  @override
  State<LiquidGlassActivityIndicator> createState() =>
      _LiquidGlassActivityIndicatorState();
}

class _LiquidGlassActivityIndicatorState
    extends State<LiquidGlassActivityIndicator> {
  Map<String, dynamic> _params() => <String, dynamic>{
        'size': widget.size,
        'tint': (widget.tint ?? LiquidGlassTheme.of(context).tint)?.toARGB32(),
        'respectAccessibility': LiquidGlassTheme.of(context).respectAccessibility,
      };

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: widget.tint,
        ),
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: UiKitView(
        viewType: _kActivityIndicatorViewType,
        creationParams: _params(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (int id) {},
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
      ),
    );
  }
}
