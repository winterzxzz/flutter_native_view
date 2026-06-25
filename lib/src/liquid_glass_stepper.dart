import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_theme.dart';

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
    this.tint,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int step;
  final int? min;
  final int? max;

  /// Optional tint color. Falls back to the [LiquidGlassTheme] tint.
  final Color? tint;

  @override
  State<LiquidGlassStepper> createState() => _LiquidGlassStepperState();
}

class _LiquidGlassStepperState extends State<LiquidGlassStepper>
    with GlassPlatformViewMixin<LiquidGlassStepper> {
  @override
  String get glassViewType => _kStepperViewType;

  @override
  bool get measuresSize => true;

  @override
  Map<String, dynamic> buildParams() {
    final LiquidGlassThemeData t = LiquidGlassTheme.of(context);
    return <String, dynamic>{
      'value': widget.value,
      'step': widget.step,
      'min': widget.min,
      'max': widget.max,
      'tint': (widget.tint ?? t.tint)?.toARGB32(),
      'respectAccessibility': t.respectAccessibility,
    };
  }

  @override
  Future<dynamic> handleCall(MethodCall call) async {
    if (call.method == 'onChanged') widget.onChanged(call.arguments as int);
    return null;
  }

  @override
  void didUpdateWidget(LiquidGlassStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncConfig();
  }

  @override
  Widget build(BuildContext context) {
    if (!isGlassPlatform) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
    return glassView(estimatedSize: const Size(160, 44));
  }
}
