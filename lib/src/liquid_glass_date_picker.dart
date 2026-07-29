import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_style.dart';

const String _kDatePickerViewType = 'liquid_glass_native/date_picker';

/// Components displayed by the native compact date picker.
enum LiquidGlassDatePickerComponents { date, time, dateAndTime }

/// A controlled native compact date picker for years 1 through 9999.
class LiquidGlassDatePicker extends StatefulWidget {
  LiquidGlassDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.minimumDate,
    this.maximumDate,
    this.components = LiquidGlassDatePickerComponents.date,
    this.controlStyle,
    this.semanticLabel,
  }) : assert(
         _isSupportedPickerDate(value) &&
             (minimumDate == null || _isSupportedPickerDate(minimumDate)) &&
             (maximumDate == null || _isSupportedPickerDate(maximumDate)),
       ),
       assert(
         minimumDate == null ||
             maximumDate == null ||
             !minimumDate.isAfter(maximumDate),
       ),
       assert(minimumDate == null || !value.isBefore(minimumDate)),
       assert(maximumDate == null || !value.isAfter(maximumDate));

  final DateTime value;
  final ValueChanged<DateTime>? onChanged;
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final LiquidGlassDatePickerComponents components;
  final LiquidGlassControlStyle? controlStyle;
  final String? semanticLabel;

  @override
  State<LiquidGlassDatePicker> createState() => _LiquidGlassDatePickerState();
}

bool _isSupportedPickerDate(DateTime value) =>
    value.year >= 1 && value.year <= 9999;

class _LiquidGlassDatePickerState extends State<LiquidGlassDatePicker>
    with GlassPlatformViewMixin<LiquidGlassDatePicker> {
  @override
  String get glassViewType => _kDatePickerViewType;

  @override
  bool get measuresSize => true;

  @override
  Map<String, Object?> buildParams() {
    final LiquidGlassControlStyle control = resolveControlStyle(
      context,
      widget.controlStyle,
    );
    return <String, Object?>{
      'value': widget.value.millisecondsSinceEpoch,
      'minimumDate': widget.minimumDate?.millisecondsSinceEpoch,
      'maximumDate': widget.maximumDate?.millisecondsSinceEpoch,
      'components': widget.components.name,
      'enabled': widget.onChanged != null,
      'accessibilityLabel': widget.semanticLabel,
      ...encodeControlStyle(control),
    };
  }

  @override
  Future<Object?> handleCall(MethodCall call) async {
    if (call.method == 'onChanged' && call.arguments is num) {
      final int milliseconds = (call.arguments as num).toInt();
      dispatchControlledNativeState(
        <String, Object?>{'value': milliseconds},
        () => widget.onChanged?.call(
          DateTime.fromMillisecondsSinceEpoch(milliseconds),
        ),
      );
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
          icon: Icon(
            widget.components == LiquidGlassDatePickerComponents.time
                ? Icons.schedule
                : Icons.calendar_month,
          ),
          label: Text(_fallbackLabel(widget.value)),
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
      estimatedSize: Size(190, control.size.minimumDimension),
      gesture: GlassGesture.eager,
    );
  }

  String _fallbackLabel(DateTime value) {
    final String date =
        '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    final String time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return switch (widget.components) {
      LiquidGlassDatePickerComponents.date => date,
      LiquidGlassDatePickerComponents.time => time,
      LiquidGlassDatePickerComponents.dateAndTime => '$date $time',
    };
  }

  Future<void> _showFallback() async {
    DateTime next = widget.value;
    if (widget.components != LiquidGlassDatePickerComponents.time) {
      final DateTime? date = await showDatePicker(
        context: context,
        initialDate: widget.value,
        firstDate:
            widget.minimumDate ??
            DateTime((widget.value.year - 100).clamp(1, 9999).toInt(), 1, 1),
        lastDate:
            widget.maximumDate ??
            DateTime((widget.value.year + 100).clamp(1, 9999).toInt(), 12, 31),
      );
      if (date == null || !mounted) return;
      next = DateTime(
        date.year,
        date.month,
        date.day,
        widget.value.hour,
        widget.value.minute,
      );
    }
    if (widget.components != LiquidGlassDatePickerComponents.date) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(widget.value),
      );
      if (time == null) return;
      next = DateTime(next.year, next.month, next.day, time.hour, time.minute);
    }
    if (widget.minimumDate case final DateTime minimum
        when next.isBefore(minimum)) {
      next = minimum;
    }
    if (widget.maximumDate case final DateTime maximum
        when next.isAfter(maximum)) {
      next = maximum;
    }
    widget.onChanged?.call(next);
  }
}
