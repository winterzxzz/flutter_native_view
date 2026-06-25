import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';

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

class _LiquidGlassColorPickerState extends State<LiquidGlassColorPicker>
    with GlassPlatformViewMixin<LiquidGlassColorPicker> {
  @override
  String get glassViewType => _kColorPickerViewType;

  @override
  bool get measuresSize => true;

  @override
  Map<String, dynamic> buildParams() => <String, dynamic>{
        'color': widget.value.toARGB32(),
      };

  @override
  Future<dynamic> handleCall(MethodCall call) async {
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
  }

  @override
  void didUpdateWidget(LiquidGlassColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Color is the only prop and it changes continuously while dragging the
    // wheel, so use the lightweight `setValue` instead of a full re-measure.
    if (oldWidget.value != widget.value) {
      channel?.invokeMethod<void>('setValue', widget.value.toARGB32());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isGlassPlatform) {
      return FilledButton.icon(
        icon: Icon(Icons.palette, color: widget.value),
        label: Text(widget.value.toARGB32().toRadixString(16)),
        onPressed: () async {
          final Color? picked = await showDialog<Color>(
            context: context,
            builder: (BuildContext ctx) {
              return SimpleDialog(
                title: const Text('Pick a color'),
                children: <Widget>[
                  for (final Color c in _presets)
                    SimpleDialogOption(
                      onPressed: () => Navigator.of(ctx).pop(c),
                      child: Row(
                        children: <Widget>[
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
    return glassView(estimatedSize: const Size(60, 44));
  }
}

const List<Color> _presets = <Color>[
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
