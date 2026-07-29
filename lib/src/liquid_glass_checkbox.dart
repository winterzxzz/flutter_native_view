import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_style.dart';

const String _kCheckboxViewType = 'liquid_glass_native/checkbox';

/// A controlled custom native checkbox with Liquid Glass on iOS 26+.
class LiquidGlassCheckbox extends StatefulWidget {
  const LiquidGlassCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.style,
    this.controlStyle,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final LiquidGlassStyle? style;
  final LiquidGlassControlStyle? controlStyle;
  final String? semanticLabel;

  @override
  State<LiquidGlassCheckbox> createState() => _LiquidGlassCheckboxState();
}

class _LiquidGlassCheckboxState extends State<LiquidGlassCheckbox>
    with GlassPlatformViewMixin<LiquidGlassCheckbox> {
  @override
  String get glassViewType => _kCheckboxViewType;

  @override
  Map<String, Object?> buildParams() {
    final LiquidGlassStyle glass = resolveGlassStyle(context, widget.style);
    final LiquidGlassControlStyle control = resolveControlStyle(
      context,
      widget.controlStyle,
    );
    return <String, Object?>{
      'value': widget.value,
      'enabled': widget.onChanged != null,
      'accessibilityLabel': widget.semanticLabel,
      ...encodeStyles(glass, control),
    };
  }

  @override
  Future<Object?> handleCall(MethodCall call) async {
    if (call.method == 'onChanged' && call.arguments is bool) {
      final bool value = call.arguments as bool;
      dispatchControlledNativeState(<String, Object?>{
        'value': value,
      }, () => widget.onChanged?.call(value));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final LiquidGlassStyle glass = resolveGlassStyle(context, widget.style);
    final LiquidGlassControlStyle control = resolveControlStyle(
      context,
      widget.controlStyle,
    );
    final double size = control.size.minimumDimension;
    if (!isGlassPlatform) {
      return applyFallbackControlStyle(
        controlStyle: control,
        enabled: widget.onChanged != null,
        child: SizedBox.square(
          dimension: size,
          child: FittedBox(
            child: Semantics(
              label: widget.semanticLabel,
              child: Checkbox(
                value: widget.value,
                onChanged: widget.onChanged == null
                    ? null
                    : (bool? value) {
                        if (value != null) widget.onChanged!(value);
                      },
                activeColor: glass.tint,
                checkColor: control.foregroundColor,
                shape: fallbackOutlinedBorder(glass.shape),
              ),
            ),
          ),
        ),
      );
    }
    return glassView(width: size, height: size, gesture: GlassGesture.tap);
  }
}
