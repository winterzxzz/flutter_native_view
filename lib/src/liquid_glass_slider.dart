import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String _kSliderViewType = 'flutter_native_view/glass_slider';

/// A native SwiftUI slider with Liquid Glass styling on iOS 26+.
///
/// On non-iOS platforms it falls back to a Material [Slider].
class LiquidGlassSlider extends StatefulWidget {
  const LiquidGlassSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.tint,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final Color? tint;

  @override
  State<LiquidGlassSlider> createState() => _LiquidGlassSliderState();
}

class _LiquidGlassSliderState extends State<LiquidGlassSlider> {
  MethodChannel? _channel;

  Map<String, dynamic> _params() => <String, dynamic>{
        'value': widget.value,
        'min': widget.min,
        'max': widget.max,
        'tint': widget.tint?.toARGB32(),
      };

  void _onCreated(int id) {
    final MethodChannel channel = MethodChannel('$_kSliderViewType/$id');
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onChanged') widget.onChanged(call.arguments as double);
      return null;
    });
    _channel = channel;
  }

  @override
  void didUpdateWidget(LiquidGlassSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.min != widget.min ||
        oldWidget.max != widget.max) {
      _channel?.invokeMethod<void>('setValue', widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return Slider(
        value: widget.value.clamp(widget.min, widget.max),
        onChanged: widget.onChanged,
        min: widget.min,
        max: widget.max,
        activeColor: widget.tint,
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 32,
      child: UiKitView(
        viewType: _kSliderViewType,
        creationParams: _params(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<EagerGestureRecognizer>(EagerGestureRecognizer.new),
        },
      ),
    );
  }
}
