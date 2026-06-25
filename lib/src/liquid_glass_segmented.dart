import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  /// Optional tint color for the selected segment.
  final Color? tint;

  /// Forces the control's light/dark appearance instead of following the
  /// device system trait. When `null`, the system trait is used.
  final Brightness? brightness;

  @override
  State<LiquidGlassSegmentedControl> createState() =>
      _LiquidGlassSegmentedControlState();
}

class _LiquidGlassSegmentedControlState
    extends State<LiquidGlassSegmentedControl> {
  MethodChannel? _channel;
  Size? _size;

  Map<String, dynamic> _params() {
    final LiquidGlassThemeData t = LiquidGlassTheme.of(context);
    return <String, dynamic>{
      'segments': widget.segments,
      'selectedIndex': widget.selectedIndex,
      'tint': (widget.tint ?? t.tint)?.toARGB32(),
      'brightness': widget.brightness?.name,
      'respectAccessibility': t.respectAccessibility,
    };
  }

  Future<void> _onCreated(int id) async {
    final MethodChannel channel = MethodChannel('$_kSegmentedViewType/$id');
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onIndexChanged') {
        widget.onChanged((call.arguments as num).toInt());
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
  void didUpdateWidget(LiquidGlassSegmentedControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segments != widget.segments ||
        oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.tint != widget.tint ||
        oldWidget.brightness != widget.brightness) {
      _applySize(_channel?.invokeMapMethod<String, dynamic>(
              'updateConfig', _params()) ??
          Future<Map<String, dynamic>?>.value());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
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
      if (widget.brightness == null) return control;
      return Theme(
        data: ThemeData(brightness: widget.brightness!),
        child: control,
      );
    }

    final Size size = _size ?? const Size(200, 32);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: UiKitView(
        viewType: _kSegmentedViewType,
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
