import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'liquid_glass_button.dart';

const String _kButtonGroupViewType = 'flutter_native_view/glass_button_group';

/// A group of glass buttons sharing one `GlassEffectContainer` on iOS 26+.
///
/// On non-iOS platforms it falls back to a [Row] of [LiquidGlassButton].
class LiquidGlassButtonGroup extends StatefulWidget {
  const LiquidGlassButtonGroup({
    super.key,
    required this.buttons,
    this.spacing = 8,
  });

  final List<GroupButton> buttons;

  /// Spacing between buttons inside the group. Defaults to 8.
  final double spacing;

  @override
  State<LiquidGlassButtonGroup> createState() => _LiquidGlassButtonGroupState();
}

/// A single button definition inside a [LiquidGlassButtonGroup].
class GroupButton {
  const GroupButton({
    required this.id,
    this.label,
    this.sfSymbol,
    this.onPressed,
  });

  final String id;
  final String? label;
  final String? sfSymbol;
  final VoidCallback? onPressed;
}

class _LiquidGlassButtonGroupState extends State<LiquidGlassButtonGroup> {
  MethodChannel? _channel;
  Size? _size;

  Map<String, VoidCallback> get _callbacks => {
        for (final b in widget.buttons)
          b.id: b.onPressed ?? () {},
      };

  List<Map<String, dynamic>> _buttonsJson() => widget.buttons
      .map((b) => <String, dynamic>{
            'id': b.id,
            'label': b.label,
            'sfSymbol': b.sfSymbol,
          })
      .toList(growable: false);

  Map<String, dynamic> _params() => <String, dynamic>{
        'buttons': _buttonsJson(),
        'spacing': widget.spacing,
      };

  Future<void> _onCreated(int id) async {
    final MethodChannel channel = MethodChannel('$_kButtonGroupViewType/$id');
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onPressed') {
        final String? buttonId = call.arguments as String?;
        if (buttonId != null) {
          _callbacks[buttonId]?.call();
        }
      }
      return null;
    });
    _channel = channel;
    await _applySize(
        channel.invokeMapMethod<String, dynamic>('getIntrinsicSize'));
  }

  Future<void> _applySize(Future<Map<String, dynamic>?> call) async {
    final Map<String, dynamic>? res = await call;
    if (res != null && mounted) {
      setState(() {
        _size = Size(
          (res['width'] as num).toDouble(),
          (res['height'] as num).toDouble(),
        );
      });
    }
  }

  @override
  void didUpdateWidget(LiquidGlassButtonGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    _channel
        ?.invokeMapMethod<String, dynamic>('updateConfig', _params());
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.buttons.map((b) {
          return LiquidGlassButton(
            label: b.label ?? '',
            onPressed: b.onPressed,
          );
        }).toList(growable: false),
      );
    }

    final Size size = _size ?? const Size(200, 44);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: UiKitView(
        viewType: _kButtonGroupViewType,
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
