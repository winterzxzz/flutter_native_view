import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_style.dart';

const String _kToggleViewType = 'liquid_glass_native/toggle';

/// A controlled system SwiftUI toggle with a size-aware Material fallback.
class LiquidGlassSwitch extends StatefulWidget {
  const LiquidGlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.controlStyle,
    this.semanticLabel,
  });

  final bool value;

  /// Null disables the control.
  final ValueChanged<bool>? onChanged;
  final LiquidGlassControlStyle? controlStyle;
  final String? semanticLabel;

  @override
  State<LiquidGlassSwitch> createState() => _LiquidGlassSwitchState();
}

class _LiquidGlassSwitchState extends State<LiquidGlassSwitch>
    with GlassPlatformViewMixin<LiquidGlassSwitch> {
  @override
  String get glassViewType => _kToggleViewType;

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
      'enabled': widget.onChanged != null,
      'accessibilityLabel': widget.semanticLabel,
      ...encodeControlStyle(control),
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
    final LiquidGlassControlStyle control = resolveControlStyle(
      context,
      widget.controlStyle,
    );
    if (!isGlassPlatform) {
      final double dimension = control.size.minimumDimension;
      return applyFallbackControlStyle(
        controlStyle: control,
        enabled: widget.onChanged != null,
        child: SizedBox(
          width: dimension * 1.2,
          height: dimension,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Semantics(
              label: widget.semanticLabel,
              child: Switch(
                value: widget.value,
                onChanged: widget.onChanged,
                activeThumbColor: control.tintColor,
              ),
            ),
          ),
        ),
      );
    }
    return glassView(
      estimatedSize: Size(
        control.size.minimumDimension * 1.2,
        control.size.minimumDimension * 0.75,
      ),
      gesture: GlassGesture.eager,
    );
  }
}
