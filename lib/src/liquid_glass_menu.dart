import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'liquid_glass_theme.dart';

const String _kMenuViewType = 'flutter_native_view/glass_menu';

/// A single entry inside a [LiquidGlassMenu].
class MenuItem {
  const MenuItem({required this.id, required this.title, this.sfSymbol});

  /// Stable identifier passed to [LiquidGlassMenu.onSelected] when tapped.
  final String id;

  /// Visible row text.
  final String title;

  /// Optional SF Symbol shown beside the title.
  final String? sfSymbol;
}

/// A native pull-down menu button with Liquid Glass styling on iOS 26+.
///
/// Tapping the button presents a native menu of [items]; the selected item's
/// id is reported through [onSelected]. On non-iOS platforms it falls back to a
/// Material [PopupMenuButton].
class LiquidGlassMenu extends StatefulWidget {
  const LiquidGlassMenu({
    super.key,
    required this.label,
    required this.items,
    required this.onSelected,
    this.sfSymbol,
    this.tint,
  });

  /// Text shown on the menu button itself.
  final String label;

  /// The selectable rows presented when the menu opens.
  final List<MenuItem> items;

  /// Called with the [MenuItem.id] of the tapped row.
  final ValueChanged<String> onSelected;

  /// Optional SF Symbol shown on the button before the label.
  final String? sfSymbol;

  /// Optional glass tint color.
  final Color? tint;

  @override
  State<LiquidGlassMenu> createState() => _LiquidGlassMenuState();
}

class _LiquidGlassMenuState extends State<LiquidGlassMenu> {
  MethodChannel? _channel;
  Size? _size;

  Map<String, dynamic> _params() => <String, dynamic>{
        'label': widget.label,
        'sfSymbol': widget.sfSymbol ?? '',
        'items': widget.items
            .map((MenuItem m) => <String, dynamic>{
                  'id': m.id,
                  'title': m.title,
                  'sfSymbol': m.sfSymbol ?? '',
                })
            .toList(),
        'tint': (widget.tint ?? LiquidGlassTheme.of(context).tint)?.toARGB32(),
        'respectAccessibility': LiquidGlassTheme.of(context).respectAccessibility,
      };

  Future<void> _onCreated(int id) async {
    final MethodChannel channel = MethodChannel('$_kMenuViewType/$id');
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onSelected') {
        widget.onSelected(call.arguments as String);
      }
      return null;
    });
    _channel = channel;
    await _applySize(channel.invokeMapMethod<String, dynamic>('getIntrinsicSize'));
  }

  Future<void> _applySize(Future<Map<String, dynamic>?> call) async {
    final Map<String, dynamic>? res = await call;
    if (res != null && mounted) {
      setState(() {
        _size = Size((res['width'] as num).toDouble(), (res['height'] as num).toDouble());
      });
    }
  }

  @override
  void didUpdateWidget(LiquidGlassMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.label != widget.label ||
        oldWidget.items != widget.items ||
        oldWidget.tint != widget.tint) {
      _applySize(_channel?.invokeMapMethod<String, dynamic>('updateConfig', _params()) ??
          Future<Map<String, dynamic>?>.value());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return PopupMenuButton<String>(
        onSelected: widget.onSelected,
        itemBuilder: (BuildContext context) => widget.items
            .map((MenuItem m) => PopupMenuItem<String>(
                  value: m.id,
                  child: Text(m.title),
                ))
            .toList(),
        child: Text(widget.label),
      );
    }

    final Size size = _size ?? const Size(100, 44);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: UiKitView(
        viewType: _kMenuViewType,
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
