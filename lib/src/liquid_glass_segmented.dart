import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_style.dart';

const String _kSegmentedViewType = 'liquid_glass_native/segmented';

/// A typed selectable segment.
@immutable
final class LiquidGlassSegment<T> {
  const LiquidGlassSegment({
    required this.value,
    required this.label,
    this.symbol,
  }) : assert(label.length > 0);

  final T value;
  final String label;
  final LiquidGlassSymbol? symbol;
}

/// A typed, controlled system segmented control.
class LiquidGlassSegmentedControl<T> extends StatefulWidget {
  const LiquidGlassSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
    this.controlStyle,
    this.semanticLabel,
  }) : assert(segments.length > 1);

  final List<LiquidGlassSegment<T>> segments;
  final T value;
  final ValueChanged<T>? onChanged;
  final LiquidGlassControlStyle? controlStyle;
  final String? semanticLabel;

  @override
  State<LiquidGlassSegmentedControl<T>> createState() =>
      _LiquidGlassSegmentedControlState<T>();
}

class _LiquidGlassSegmentedControlState<T>
    extends State<LiquidGlassSegmentedControl<T>>
    with GlassPlatformViewMixin<LiquidGlassSegmentedControl<T>> {
  @override
  String get glassViewType => _kSegmentedViewType;

  @override
  bool get measuresSize => true;

  int get _selectedIndex => widget.segments.indexWhere(
    (LiquidGlassSegment<T> segment) => segment.value == widget.value,
  );

  void _debugValidate() {
    assert(() {
      if (_selectedIndex < 0) {
        throw FlutterError(
          'LiquidGlassSegmentedControl.value must match one segment value.',
        );
      }
      final Set<T> values = widget.segments
          .map((LiquidGlassSegment<T> segment) => segment.value)
          .toSet();
      if (values.length != widget.segments.length) {
        throw FlutterError(
          'LiquidGlassSegmentedControl segment values must be unique.',
        );
      }
      return true;
    }());
  }

  @override
  Map<String, Object?> buildParams() {
    _debugValidate();
    final LiquidGlassControlStyle control = resolveControlStyle(
      context,
      widget.controlStyle,
    );
    return <String, Object?>{
      'segments': widget.segments
          .map(
            (LiquidGlassSegment<T> segment) => <String, Object?>{
              'label': segment.label,
              'symbol': segment.symbol?.name,
            },
          )
          .toList(growable: false),
      'selectedIndex': _selectedIndex,
      'enabled': widget.onChanged != null,
      'accessibilityLabel': widget.semanticLabel,
      ...encodeControlStyle(control),
    };
  }

  @override
  Future<Object?> handleCall(MethodCall call) async {
    if (call.method == 'onChanged' && call.arguments is num) {
      final int index = (call.arguments as num).toInt();
      if (index >= 0 && index < widget.segments.length) {
        dispatchControlledNativeState(<String, Object?>{
          'selectedIndex': index,
        }, () => widget.onChanged?.call(widget.segments[index].value));
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    _debugValidate();
    final LiquidGlassControlStyle control = resolveControlStyle(
      context,
      widget.controlStyle,
    );
    if (!isGlassPlatform) {
      final Widget segmented = SegmentedButton<int>(
        segments: <ButtonSegment<int>>[
          for (var index = 0; index < widget.segments.length; index++)
            ButtonSegment<int>(
              value: index,
              label: Text(widget.segments[index].label),
              icon: widget.segments[index].symbol?.fallbackIcon == null
                  ? null
                  : Icon(widget.segments[index].symbol!.fallbackIcon),
            ),
        ],
        selected: <int>{_selectedIndex},
        onSelectionChanged: widget.onChanged == null
            ? null
            : (Set<int> selected) {
                widget.onChanged!(widget.segments[selected.first].value);
              },
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll<Color?>(
            control.foregroundColor,
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            return states.contains(WidgetState.selected)
                ? control.tintColor
                : null;
          }),
          minimumSize: WidgetStatePropertyAll<Size>(
            Size(0, control.size.minimumDimension),
          ),
        ),
      );
      return applyFallbackControlStyle(
        child: segmented,
        controlStyle: control,
        enabled: widget.onChanged != null,
      );
    }
    return glassView(
      estimatedSize: Size(220, control.size.minimumDimension),
      gesture: GlassGesture.eager,
    );
  }
}
