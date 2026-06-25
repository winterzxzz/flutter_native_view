import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_theme.dart';

const String _kSegmentedViewType = 'flutter_native_view/glass_segmented';

/// A native iOS segmented control (`UISegmentedControl`) with Liquid Glass
/// styling on iOS 26+. On non-iOS platforms it falls back to a Material
/// [SegmentedButton].
///
/// This is a controlled widget: pass [selectedIndex] in and update your state
/// from [onChanged].
class LiquidGlassSegmentedControl extends StatefulWidget {
  const LiquidGlassSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    this.tint,
    this.brightness,
  });

  /// Ordered segment titles.
  final List<String> segments;

  /// Index into [segments] of the currently selected segment.
  final int selectedIndex;

  /// Called with the index of the newly selected segment.
  final ValueChanged<int> onChanged;

  /// Optional tint color for the selected segment. Falls back to the
  /// [LiquidGlassTheme] tint.
  final Color? tint;

  /// Forces the control's light/dark appearance instead of following the
  /// device system trait. When `null`, falls back to the [LiquidGlassTheme]
  /// brightness, otherwise the system trait is used.
  final Brightness? brightness;

  @override
  State<LiquidGlassSegmentedControl> createState() =>
      _LiquidGlassSegmentedControlState();
}

class _LiquidGlassSegmentedControlState
    extends State<LiquidGlassSegmentedControl>
    with GlassPlatformViewMixin<LiquidGlassSegmentedControl> {
  @override
  String get glassViewType => _kSegmentedViewType;

  @override
  bool get measuresSize => true;

  Brightness? get _brightness =>
      widget.brightness ?? LiquidGlassTheme.of(context).brightness;

  @override
  Map<String, dynamic> buildParams() {
    final LiquidGlassThemeData t = LiquidGlassTheme.of(context);
    return <String, dynamic>{
      'segments': widget.segments,
      'selectedIndex': widget.selectedIndex,
      'tint': (widget.tint ?? t.tint)?.toARGB32(),
      'brightness': _brightness?.name,
      'respectAccessibility': t.respectAccessibility,
    };
  }

  @override
  Future<dynamic> handleCall(MethodCall call) async {
    if (call.method == 'onIndexChanged') {
      widget.onChanged((call.arguments as num).toInt());
    }
    return null;
  }

  @override
  void didUpdateWidget(LiquidGlassSegmentedControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncConfig();
  }

  @override
  Widget build(BuildContext context) {
    if (!isGlassPlatform) {
      final Widget control = SegmentedButton<String>(
        segments: widget.segments
            .map((String s) => ButtonSegment<String>(value: s, label: Text(s)))
            .toList(),
        selected: <String>{widget.segments[widget.selectedIndex]},
        onSelectionChanged: (Set<String> sel) {
          final int idx = widget.segments.indexOf(sel.first);
          if (idx >= 0) widget.onChanged(idx);
        },
      );
      final Brightness? b = _brightness;
      if (b == null) return control;
      return Theme(data: ThemeData(brightness: b), child: control);
    }
    return glassView(
      estimatedSize: const Size(200, 32),
      gesture: GlassGesture.eager,
    );
  }
}
