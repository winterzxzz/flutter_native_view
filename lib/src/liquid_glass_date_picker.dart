import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class _LiquidGlassDatePickerState extends State<LiquidGlassDatePicker> {
  MethodChannel? _channel;
  Size? _size;

  int _millis(DateTime d) => d.millisecondsSinceEpoch;

  Map<String, dynamic> _params() => <String, dynamic>{
        'value': _millis(widget.value),
        'min': widget.min?.millisecondsSinceEpoch,
        'max': widget.max?.millisecondsSinceEpoch,
        'mode': widget.mode,
      };

  Future<void> _onCreated(int id) async {
    final MethodChannel channel = MethodChannel('$_kDatePickerViewType/$id');
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onChanged') {
        final int millis = call.arguments as int;
        widget.onChanged(
            DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toLocal());
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
  void didUpdateWidget(LiquidGlassDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _channel?.invokeMethod<void>('setValue', _millis(widget.value));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
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

    final Size size = _size ?? const Size(200, 44);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: UiKitView(
        viewType: _kDatePickerViewType,
        creationParams: _params(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<EagerGestureRecognizer>(EagerGestureRecognizer.new),
        },
      ),
    );
  }
}
