import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String _kSegmentedViewType = 'flutter_native_view/glass_segmented';

class LiquidGlassSegmentedControl extends StatefulWidget {
  const LiquidGlassSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    this.tint,
  });

  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color? tint;

  @override
  State<LiquidGlassSegmentedControl> createState() =>
      _LiquidGlassSegmentedControlState();
}

class _LiquidGlassSegmentedControlState
    extends State<LiquidGlassSegmentedControl> {
  MethodChannel? _channel;
  Size? _size;

  Map<String, dynamic> _params() => <String, dynamic>{
        'segments': widget.segments,
        'selectedIndex': widget.selectedIndex,
        'tint': widget.tint?.toARGB32(),
      };

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
        oldWidget.tint != widget.tint) {
      _applySize(_channel?.invokeMapMethod<String, dynamic>(
              'updateConfig', _params()) ??
          Future<Map<String, dynamic>?>.value());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return SegmentedButton<String>(
        segments: widget.segments
            .map((String s) => ButtonSegment<String>(value: s, label: Text(s)))
            .toList(),
        selected: <String>{widget.segments[widget.selectedIndex]},
        onSelectionChanged: (Set<String> sel) {
          final int idx = widget.segments.indexOf(sel.first);
          if (idx >= 0) widget.onChanged(idx);
        },
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
