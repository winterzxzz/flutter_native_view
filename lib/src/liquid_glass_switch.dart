import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  /// Optional tint color for the on state.
  final Color? tint;

  @override
  State<LiquidGlassSwitch> createState() => _LiquidGlassSwitchState();
}

class _LiquidGlassSwitchState extends State<LiquidGlassSwitch> {
  MethodChannel? _channel;

  Map<String, dynamic> _params() => <String, dynamic>{
        'value': widget.value,
        'tint': (widget.tint ?? LiquidGlassTheme.of(context).tint)?.toARGB32(),
        'respectAccessibility': LiquidGlassTheme.of(context).respectAccessibility,
      };

  void _onCreated(int id) {
    final MethodChannel channel = MethodChannel('$_kToggleViewType/$id');
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onChanged') widget.onChanged(call.arguments as bool);
      return null;
    });
    _channel = channel;
  }

  @override
  void didUpdateWidget(LiquidGlassSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _channel?.invokeMethod<void>('setValue', widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return Switch(value: widget.value, onChanged: widget.onChanged);
    }

    return SizedBox(
      width: 52,
      height: 32,
      child: UiKitView(
        viewType: _kToggleViewType,
        creationParams: _params(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onCreated,
        // The native switch is interactive (tap + drag), so it must receive
        // the raw touches.
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<EagerGestureRecognizer>(EagerGestureRecognizer.new),
        },
      ),
    );
  }
}
