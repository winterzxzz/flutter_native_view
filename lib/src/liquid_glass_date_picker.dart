import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';

const String _kDatePickerViewType = 'flutter_native_view/glass_date_picker';

/// A native SwiftUI DatePicker with Liquid Glass styling on iOS 26+.
///
/// On non-iOS platforms it falls back to a button that opens Flutter's
/// [showDatePicker].
class LiquidGlassDatePicker extends StatefulWidget {
  const LiquidGlassDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.mode,
  });

  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? min;
  final DateTime? max;

  /// The display mode: 'date', 'time', or 'dateAndTime'.
  /// Defaults to 'date' on the native side.
  final String? mode;

  @override
  State<LiquidGlassDatePicker> createState() => _LiquidGlassDatePickerState();
}

class _LiquidGlassDatePickerState extends State<LiquidGlassDatePicker>
    with GlassPlatformViewMixin<LiquidGlassDatePicker> {
  @override
  String get glassViewType => _kDatePickerViewType;

  @override
  bool get measuresSize => true;

  @override
  Map<String, dynamic> buildParams() => <String, dynamic>{
        'value': widget.value.millisecondsSinceEpoch,
        'min': widget.min?.millisecondsSinceEpoch,
        'max': widget.max?.millisecondsSinceEpoch,
        'mode': widget.mode,
      };

  @override
  Future<dynamic> handleCall(MethodCall call) async {
    if (call.method == 'onChanged') {
      final int millis = call.arguments as int;
      widget.onChanged(
          DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toLocal());
    }
    return null;
  }

  @override
  void didUpdateWidget(LiquidGlassDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncConfig();
  }

  @override
  Widget build(BuildContext context) {
    if (!isGlassPlatform) {
      return FilledButton.icon(
        icon: const Icon(Icons.calendar_month),
        label: Text(
          '${widget.value.year}-${widget.value.month.toString().padLeft(2, '0')}-${widget.value.day.toString().padLeft(2, '0')}',
        ),
        onPressed: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: widget.value,
            firstDate: widget.min ?? DateTime(2000),
            lastDate: widget.max ?? DateTime(2100),
          );
          if (picked != null && picked != widget.value) {
            widget.onChanged(picked);
          }
        },
      );
    }
    return glassView(
      estimatedSize: const Size(200, 44),
      gesture: GlassGesture.eager,
    );
  }
}
