import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// View type id registered by the native switch factory.
const String kGlassSwitchViewType = 'flutter_native_view/glass_switch';

/// A native SwiftUI `Toggle` rendered with Liquid Glass.
///
/// Unlike [LiquidGlass], the switch is fully native and interactive: the toggle
/// animation runs in SwiftUI and the new value is bridged back to Flutter.
class LiquidGlassSwitch extends StatefulWidget {
  const LiquidGlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.tint,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? tint;

  @override
  State<LiquidGlassSwitch> createState() => _LiquidGlassSwitchState();
}

class _LiquidGlassSwitchState extends State<LiquidGlassSwitch> {
  MethodChannel? _channel;

  @override
  void didUpdateWidget(LiquidGlassSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Push externally-driven value changes down to the native toggle.
    if (oldWidget.value != widget.value) {
      _channel?.invokeMethod<void>('setValue', widget.value);
    }
  }

  void _onPlatformViewCreated(int id) {
    final MethodChannel channel =
        MethodChannel('${kGlassSwitchViewType}_$id');
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onChanged') {
        widget.onChanged(call.arguments as bool);
      }
      return null;
    });
    _channel = channel;
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      // Off iOS: fall back to the Material switch.
      return Switch(value: widget.value, onChanged: widget.onChanged);
    }

    return SizedBox(
      width: 64,
      height: 36,
      child: UiKitView(
        viewType: kGlassSwitchViewType,
        creationParams: <String, dynamic>{
          'value': widget.value,
          'tintColor': widget.tint?.toARGB32(),
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        // The native toggle is interactive, so it must receive touches.
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
        },
      ),
    );
  }
}
