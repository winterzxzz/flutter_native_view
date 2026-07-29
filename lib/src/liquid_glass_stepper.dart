import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_style.dart';

const String _kStepperViewType = 'liquid_glass_native/stepper';

/// A controlled system SwiftUI integer stepper.
class LiquidGlassStepper extends StatefulWidget {
  const LiquidGlassStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.min,
    this.max,
    this.controlStyle,
    this.semanticLabel,
  }) : assert(step > 0),
       assert(min == null || max == null || min <= max),
       assert(min == null || value >= min),
       assert(max == null || value <= max);

  final int value;
  final ValueChanged<int>? onChanged;
  final int step;
  final int? min;
  final int? max;
  final LiquidGlassControlStyle? controlStyle;
  final String? semanticLabel;

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
  Map<String, Object?> buildParams() {
    final LiquidGlassControlStyle control = resolveControlStyle(
      context,
      widget.controlStyle,
    );
    return <String, Object?>{
      'value': widget.value,
      'step': widget.step,
      'min': widget.min,
      'max': widget.max,
      'enabled': widget.onChanged != null,
      'accessibilityLabel': widget.semanticLabel,
      ...encodeControlStyle(control),
    };
  }

  @override
  Future<Object?> handleCall(MethodCall call) async {
    if (call.method == 'onChanged' && call.arguments is num) {
      final int value = (call.arguments as num).toInt();
      dispatchControlledNativeState(<String, Object?>{
        'value': value,
      }, () => widget.onChanged?.call(value));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final LiquidGlassControlStyle control = resolveControlStyle(
      context,
      widget.controlStyle,
    );
    if (!isGlassPlatform) {
      final double dimension = control.size.minimumDimension;
      final ButtonStyle iconStyle = IconButton.styleFrom(
        minimumSize: Size.square(dimension),
      );
      return applyFallbackControlStyle(
        controlStyle: control,
        enabled: widget.onChanged != null,
        child: Semantics(
          label: widget.semanticLabel,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.remove),
                color: control.tintColor ?? control.foregroundColor,
                style: iconStyle,
                onPressed:
                    widget.onChanged == null ||
                        (widget.min != null && widget.value <= widget.min!)
                    ? null
                    : () => widget.onChanged!(_nextValue(-widget.step)),
              ),
              Text('${widget.value}'),
              IconButton(
                icon: const Icon(Icons.add),
                color: control.tintColor ?? control.foregroundColor,
                style: iconStyle,
                onPressed:
                    widget.onChanged == null ||
                        (widget.max != null && widget.value >= widget.max!)
                    ? null
                    : () => widget.onChanged!(_nextValue(widget.step)),
              ),
            ],
          ),
        ),
      );
    }
    return glassView(
      estimatedSize: Size(150, control.size.minimumDimension),
      gesture: GlassGesture.tap,
    );
  }

  int _nextValue(int delta) {
    var next = widget.value + delta;
    if (widget.min case final int minimum when next < minimum) next = minimum;
    if (widget.max case final int maximum when next > maximum) next = maximum;
    return next;
  }
}
