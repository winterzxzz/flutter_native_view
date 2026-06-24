import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String _kColorPickerViewType = 'flutter_native_view/glass_color_picker';

/// A native SwiftUI ColorPicker with Liquid Glass styling on iOS 26+.
///
/// On non-iOS platforms it falls back to a button that opens a simple Flutter
/// color dialog.
class LiquidGlassColorPicker extends StatefulWidget {
  const LiquidGlassColorPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Color value;
  final ValueChanged<Color> onChanged;

  @override
  State<LiquidGlassColorPicker> createState() => _LiquidGlassColorPickerState();
}

class _LiquidGlassColorPickerState extends State<LiquidGlassColorPicker> {
  MethodChannel? _channel;
  Size? _size;

  Map<String, dynamic> _params() => <String, dynamic>{
        'color': widget.value.toARGB32(),
      };

  Future<void> _onCreated(int id) async {
    final MethodChannel channel = MethodChannel('$_kColorPickerViewType/$id');
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onChanged') {
        final int argb = call.arguments as int;
        widget.onChanged(Color.fromARGB(
          (argb >> 24) & 0xFF,
          (argb >> 16) & 0xFF,
          (argb >> 8) & 0xFF,
          argb & 0xFF,
        ));
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
  void didUpdateWidget(LiquidGlassColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _channel?.invokeMethod<void>('setValue', widget.value.toARGB32());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return FilledButton.icon(
        icon: Icon(Icons.palette, color: widget.value),
        label: Text(widget.value.toARGB32().toRadixString(16)),
        onPressed: () async {
          final Color? picked = await showDialog<Color>(
            context: context,
            builder: (BuildContext ctx) {
              return SimpleDialog(
                title: const Text('Pick a color'),
                children: [
                  for (final Color c in _presets)
                    SimpleDialogOption(
                      onPressed: () => Navigator.of(ctx).pop(c),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: c,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('#${c.toARGB32().toRadixString(16).padLeft(8, '0')}'),
                        ],
                      ),
                    ),
                ],
              );
            },
          );
          if (picked != null && picked != widget.value) {
            widget.onChanged(picked);
          }
        },
      );
    }

    final Size size = _size ?? const Size(60, 44);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: UiKitView(
        viewType: _kColorPickerViewType,
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

const List<Color> _presets = [
  Color(0xFFFF0000),
  Color(0xFF00FF00),
  Color(0xFF0000FF),
  Color(0xFFFFFF00),
  Color(0xFFFF00FF),
  Color(0xFF00FFFF),
  Color(0xFFFFFFFF),
  Color(0xFF000000),
  Color(0xFF808080),
  Color(0xFFFF6E7F),
  Color(0xFF6C63FF),
  Color(0xFF00C853),
];
