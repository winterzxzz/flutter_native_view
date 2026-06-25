import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_theme.dart';

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
    this.height = 32,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  /// Optional tint color. Falls back to the [LiquidGlassTheme] tint.
  final Color? tint;

  /// Track height. Defaults to 32. Width always fills the parent.
  final double height;

  @override
  State<LiquidGlassSlider> createState() => _LiquidGlassSliderState();
}

class _LiquidGlassSliderState extends State<LiquidGlassSlider>
    with GlassPlatformViewMixin<LiquidGlassSlider> {
  @override
  String get glassViewType => _kSliderViewType;

  @override
  Map<String, dynamic> buildParams() {
    final LiquidGlassThemeData t = LiquidGlassTheme.of(context);
    return <String, dynamic>{
      'value': widget.value,
      'min': widget.min,
      'max': widget.max,
      'tint': (widget.tint ?? t.tint)?.toARGB32(),
      'respectAccessibility': t.respectAccessibility,
    };
  }

  @override
  Future<dynamic> handleCall(MethodCall call) async {
    if (call.method == 'onChanged') widget.onChanged(call.arguments as double);
    return null;
  }

  @override
  void didUpdateWidget(LiquidGlassSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncConfig();
  }

  @override
  Widget build(BuildContext context) {
    if (!isGlassPlatform) {
      return Slider(
        value: widget.value.clamp(widget.min, widget.max),
        onChanged: widget.onChanged,
        min: widget.min,
        max: widget.max,
        activeColor: widget.tint,
      );
    }
    return glassView(
      width: double.infinity,
      height: widget.height,
      gesture: GlassGesture.eager,
    );
  }
}
