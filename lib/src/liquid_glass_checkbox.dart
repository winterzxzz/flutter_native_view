import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_theme.dart';

const String _kCheckboxViewType = 'flutter_native_view/glass_checkbox';

/// A native checkbox rendered with Liquid Glass styling on iOS 26+: a rounded
/// glass square that shows a checkmark when checked.
///
/// On non-iOS platforms it falls back to a Material [Checkbox]. This is a
/// controlled widget — pass [value] in and update your state from [onChanged].
class LiquidGlassCheckbox extends StatefulWidget {
  const LiquidGlassCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tint,
    this.size = 28,
  });

  /// Whether the checkbox is currently checked.
  final bool value;

  /// Called with the new value when the checkbox is tapped.
  final ValueChanged<bool> onChanged;

  /// Optional tint for the checked state. Falls back to the [LiquidGlassTheme]
  /// tint.
  final Color? tint;

  /// Box size (width = height). Defaults to 28.
  final double size;

  @override
  State<LiquidGlassCheckbox> createState() => _LiquidGlassCheckboxState();
}

class _LiquidGlassCheckboxState extends State<LiquidGlassCheckbox>
    with GlassPlatformViewMixin<LiquidGlassCheckbox> {
  @override
  String get glassViewType => _kCheckboxViewType;

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
  void didUpdateWidget(LiquidGlassCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncConfig();
  }

  @override
  Widget build(BuildContext context) {
    if (!isGlassPlatform) {
      return Checkbox(
        value: widget.value,
        onChanged: (bool? v) => widget.onChanged(v ?? false),
      );
    }
    return glassView(width: widget.size, height: widget.size);
  }
}
