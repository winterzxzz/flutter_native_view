import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String _kProgressViewType = 'flutter_native_view/glass_progress';

/// A native SwiftUI linear progress bar with Liquid Glass styling on iOS 26+.
///
/// On non-iOS platforms it falls back to a Material [LinearProgressIndicator].
class LiquidGlassProgressView extends StatefulWidget {
  const LiquidGlassProgressView({
    super.key,
    this.value = 0.0,
    this.tint,
  });

  /// The current progress, from 0.0 to 1.0. Defaults to 0.0 (indeterminate).
  final double value;

  /// Optional tint color.
  final Color? tint;

  @override
  State<LiquidGlassProgressView> createState() =>
      _LiquidGlassProgressViewState();
}

class _LiquidGlassProgressViewState extends State<LiquidGlassProgressView> {
  MethodChannel? _channel;

  Map<String, dynamic> _params() => <String, dynamic>{
        'value': widget.value,
        'tint': widget.tint?.toARGB32(),
      };

  void _onCreated(int id) {
    _channel = MethodChannel('$_kProgressViewType/$id');
  }

  @override
  void didUpdateWidget(LiquidGlassProgressView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _channel?.invokeMethod<void>('setValue', widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return LinearProgressIndicator(
        value: widget.value > 0 ? widget.value : null,
        color: widget.tint,
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 8,
      child: UiKitView(
        viewType: _kProgressViewType,
        creationParams: _params(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onCreated,
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
      ),
    );
  }
}
