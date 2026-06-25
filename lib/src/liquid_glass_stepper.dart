import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String _kStepperViewType = 'flutter_native_view/glass_stepper';

/// A native SwiftUI stepper with Liquid Glass styling on iOS 26+.
///
/// On non-iOS platforms it falls back to two [IconButton]s + a label.
class LiquidGlassStepper extends StatefulWidget {
  const LiquidGlassStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.min,
    this.max,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int step;
  final int? min;
  final int? max;

  @override
  State<LiquidGlassStepper> createState() => _LiquidGlassStepperState();
}

class _LiquidGlassStepperState extends State<LiquidGlassStepper> {
  MethodChannel? _channel;
  Size? _size;

  Map<String, dynamic> _params() => <String, dynamic>{
        'value': widget.value,
        'step': widget.step,
        'min': widget.min,
        'max': widget.max,
      };

  Future<void> _onCreated(int id) async {
    final MethodChannel channel = MethodChannel('$_kStepperViewType/$id');
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onChanged') widget.onChanged(call.arguments as int);
      return null;
    });
    _channel = channel;
    await _applySize(
        channel.invokeMapMethod<String, dynamic>('getIntrinsicSize'));
  }

  Future<void> _applySize(Future<Map<String, dynamic>?> call) async {
    final Map<String, dynamic>? res = await call;
    if (res != null && mounted) {
      setState(() {
        _size = Size(
          (res['width'] as num).toDouble(),
          (res['height'] as num).toDouble(),
        );
      });
    }
  }

  @override
  void didUpdateWidget(LiquidGlassStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _channel?.invokeMethod<void>('setValue', widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: widget.min != null && widget.value <= widget.min!
                ? null
                : () => widget.onChanged(widget.value - widget.step),
          ),
          Text('${widget.value}', style: const TextStyle(fontSize: 17)),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: widget.max != null && widget.value >= widget.max!
                ? null
                : () => widget.onChanged(widget.value + widget.step),
          ),
        ],
      );
    }

    final Size size = _size ?? const Size(160, 44);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: UiKitView(
        viewType: _kStepperViewType,
        creationParams: _params(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<TapGestureRecognizer>(TapGestureRecognizer.new),
        },
      ),
    );
  }
}
