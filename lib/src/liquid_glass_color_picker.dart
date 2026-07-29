import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_style.dart';

const String _kColorPickerViewType = 'liquid_glass_native/color_picker';

/// A controlled system SwiftUI color picker.
class LiquidGlassColorPicker extends StatefulWidget {
  const LiquidGlassColorPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.supportsOpacity = true,
    this.controlStyle,
    this.semanticLabel,
  });

  final Color value;
  final ValueChanged<Color>? onChanged;
  final bool supportsOpacity;
  final LiquidGlassControlStyle? controlStyle;
  final String? semanticLabel;

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
  Map<String, Object?> buildParams() {
    final LiquidGlassControlStyle control = resolveControlStyle(
      context,
      widget.controlStyle,
    );
    return <String, Object?>{
      'value': widget.value.toARGB32(),
      'supportsOpacity': widget.supportsOpacity,
      'enabled': widget.onChanged != null,
      'accessibilityLabel': widget.semanticLabel,
      ...encodeControlStyle(control),
    };
  }

  @override
  Future<Object?> handleCall(MethodCall call) async {
    if (call.method == 'onChanged' && call.arguments is num) {
      final int argb = (call.arguments as num).toInt();
      dispatchControlledNativeState(<String, Object?>{
        'value': argb,
      }, () => widget.onChanged?.call(Color(argb)));
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
      return applyFallbackControlStyle(
        controlStyle: control,
        enabled: widget.onChanged != null,
        child: FilledButton.icon(
          onPressed: widget.onChanged == null ? null : _showFallback,
          icon: Icon(Icons.palette, color: widget.value),
          label: Text(
            '#${widget.value.toARGB32().toRadixString(16).padLeft(8, '0')}',
          ),
          style: FilledButton.styleFrom(
            foregroundColor: control.foregroundColor,
            backgroundColor: control.tintColor,
            minimumSize: Size(
              control.size.minimumDimension,
              control.size.minimumDimension,
            ),
          ),
        ),
      );
    }
    return glassView(
      estimatedSize: Size(60, control.size.minimumDimension),
      gesture: GlassGesture.eager,
    );
  }

  Future<void> _showFallback() async {
    Color selected = widget.value;
    final Color? picked = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final Color color in _fallbackColors)
                      InkWell(
                        onTap: () => setState(() {
                          selected = color.withValues(
                            alpha: widget.supportsOpacity ? selected.a : 1,
                          );
                        }),
                        borderRadius: BorderRadius.circular(6),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color:
                                  (color.toARGB32() & 0x00FFFFFF) ==
                                      (selected.toARGB32() & 0x00FFFFFF)
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: const SizedBox.square(dimension: 32),
                        ),
                      ),
                  ],
                ),
                if (widget.supportsOpacity) ...<Widget>[
                  const SizedBox(height: 16),
                  Text('Opacity ${(selected.a * 100).round()}%'),
                  Slider(
                    value: selected.a,
                    onChanged: (double alpha) => setState(
                      () => selected = selected.withValues(alpha: alpha),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(selected),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
    if (picked != null && picked != widget.value) {
      widget.onChanged?.call(picked);
    }
  }
}

const List<Color> _fallbackColors = <Color>[
  Color(0xFFFF3B30),
  Color(0xFFFF9500),
  Color(0xFFFFCC00),
  Color(0xFF34C759),
  Color(0xFF00C7BE),
  Color(0xFF007AFF),
  Color(0xFF5856D6),
  Color(0xFFAF52DE),
  Color(0xFFFF2D55),
  Color(0xFFFFFFFF),
  Color(0xFF000000),
];
