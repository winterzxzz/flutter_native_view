import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  });

  /// Whether the checkbox is currently checked.
  final bool value;

  /// Called with the new value when the checkbox is tapped.
  final ValueChanged<bool> onChanged;

  /// Optional tint for the checked state. Falls back to the [LiquidGlassTheme]
  /// tint.
  final Color? tint;

  @override
  State<LiquidGlassCheckbox> createState() => _LiquidGlassCheckboxState();
}

class _LiquidGlassCheckboxState extends State<LiquidGlassCheckbox> {
  MethodChannel? _channel;

  Map<String, dynamic> _params() {
    final LiquidGlassThemeData t = LiquidGlassTheme.of(context);
    return <String, dynamic>{
      'value': widget.value,
      'tint': (widget.tint ?? t.tint)?.toARGB32(),
      'respectAccessibility': t.respectAccessibility,
    };
  }

  void _onCreated(int id) {
    final MethodChannel channel = MethodChannel('$_kCheckboxViewType/$id');
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onChanged') widget.onChanged(call.arguments as bool);
      return null;
    });
    _channel = channel;
  }

  @override
  void didUpdateWidget(LiquidGlassCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _channel?.invokeMethod<void>('setValue', widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return Checkbox(
        value: widget.value,
        onChanged: (bool? v) => widget.onChanged(v ?? false),
      );
    }

    return SizedBox(
      width: 28,
      height: 28,
      child: UiKitView(
        viewType: _kCheckboxViewType,
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
