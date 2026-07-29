import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_style.dart';

const String _kSliderViewType = 'liquid_glass_native/slider';

/// A controlled system SwiftUI slider with validated finite bounds.
class LiquidGlassSlider extends StatefulWidget {
  const LiquidGlassSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.controlStyle,
    this.semanticLabel,
  }) : assert(min > double.negativeInfinity && max < double.infinity),
       assert(min < max),
       assert(value >= min && value <= max);

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final LiquidGlassControlStyle? controlStyle;
  final String? semanticLabel;

  @override
  State<LiquidGlassSlider> createState() => _LiquidGlassSliderState();
}

class _LiquidGlassSliderState extends State<LiquidGlassSlider>
    with GlassPlatformViewMixin<LiquidGlassSlider> {
  @override
  String get glassViewType => _kSliderViewType;

  @override
  Map<String, Object?> buildParams() {
    final LiquidGlassControlStyle control = resolveControlStyle(
      context,
      widget.controlStyle,
    );
    return <String, Object?>{
      'value': widget.value,
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
      final double value = (call.arguments as num).toDouble();
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
      return applyFallbackControlStyle(
        controlStyle: control,
        enabled: widget.onChanged != null,
        child: SizedBox(
          height: control.size.minimumDimension,
          child: Semantics(
            label: widget.semanticLabel,
            slider: true,
            child: Slider(
              value: widget.value,
              onChanged: widget.onChanged,
              min: widget.min,
              max: widget.max,
              activeColor: control.tintColor,
            ),
          ),
        ),
      );
    }
    return glassView(
      width: double.infinity,
      height: control.size.minimumDimension,
      gesture: GlassGesture.eager,
    );
  }
}
