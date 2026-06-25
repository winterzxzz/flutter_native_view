import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_theme.dart';

const String _kToggleViewType = 'flutter_native_view/glass_toggle';

/// A native SwiftUI toggle with Liquid Glass styling on iOS 26+.
///
/// On non-iOS platforms it falls back to a Material [Switch].
class LiquidGlassSwitch extends StatefulWidget {
  const LiquidGlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.tint,
    this.width = 52,
    this.height = 32,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  /// Optional tint color for the on state. Falls back to the
  /// [LiquidGlassTheme] tint.
  final Color? tint;

  /// Track width of the native switch. Defaults to 52.
  final double width;

  /// Track height of the native switch. Defaults to 32.
  final double height;

  @override
  State<LiquidGlassSwitch> createState() => _LiquidGlassSwitchState();
}

class _LiquidGlassSwitchState extends State<LiquidGlassSwitch>
    with GlassPlatformViewMixin<LiquidGlassSwitch> {
  @override
  String get glassViewType => _kToggleViewType;

  @override
  Map<String, dynamic> buildParams() {
    final LiquidGlassThemeData t = LiquidGlassTheme.of(context);
    return <String, dynamic>{
      'value': widget.value,
      'tint': (widget.tint ?? t.tint)?.toARGB32(),
      'respectAccessibility': t.respectAccessibility,
    };
  }

  @override
  Future<dynamic> handleCall(MethodCall call) async {
    if (call.method == 'onChanged') widget.onChanged(call.arguments as bool);
    return null;
  }

  @override
  void didUpdateWidget(LiquidGlassSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncConfig();
  }

  @override
  Widget build(BuildContext context) {
    if (!isGlassPlatform) {
      return Switch(value: widget.value, onChanged: widget.onChanged);
    }
    // The native switch is interactive (tap + drag), so it must receive the
    // raw touches.
    return glassView(
      width: widget.width,
      height: widget.height,
      gesture: GlassGesture.eager,
    );
  }
}
