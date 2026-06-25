import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bar_action.dart';
import 'liquid_glass_theme.dart';

const String _kNavigationBarViewType = 'flutter_native_view/glass_navigation_bar';

/// A native top navigation bar with Liquid Glass styling on iOS 26+.
///
/// On non-iOS platforms it falls back to a Material [AppBar].
class LiquidGlassNavigationBar extends StatefulWidget {
  const LiquidGlassNavigationBar({
    super.key,
    this.title,
    this.leading = const [],
    this.trailing = const [],
    this.tint,
  });

  final String? title;
  final List<BarAction> leading;
  final List<BarAction> trailing;

  /// Optional tint color applied to the bar.
  final Color? tint;

  @override
  State<LiquidGlassNavigationBar> createState() =>
      _LiquidGlassNavigationBarState();
}

class _LiquidGlassNavigationBarState extends State<LiquidGlassNavigationBar> {
  MethodChannel? _channel;

  Map<String, VoidCallback> get _callbacks => {
        for (final a in [...widget.leading, ...widget.trailing])
          a.id: a.onPressed ?? () {},
      };

  Map<String, dynamic> _params() => <String, dynamic>{
        'title': widget.title,
        'leading': widget.leading
            .map((a) => <String, dynamic>{'id': a.id, 'sfSymbol': a.sfSymbol})
            .toList(growable: false),
        'trailing': widget.trailing
            .map((a) => <String, dynamic>{'id': a.id, 'sfSymbol': a.sfSymbol})
            .toList(growable: false),
        'tint': (widget.tint ?? LiquidGlassTheme.of(context).tint)?.toARGB32(),
        'respectAccessibility': LiquidGlassTheme.of(context).respectAccessibility,
      };

  void _onCreated(int id) {
    final MethodChannel channel = MethodChannel('$_kNavigationBarViewType/$id');
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onAction') {
        final String? actionId = call.arguments as String?;
        if (actionId != null) _callbacks[actionId]?.call();
      }
      return null;
    });
    _channel = channel;
  }

  @override
  void didUpdateWidget(LiquidGlassNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _channel?.invokeMethod<void>('updateConfig', _params());
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return AppBar(
        backgroundColor: widget.tint,
        title: widget.title != null ? Text(widget.title!) : null,
        leading: widget.leading.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.leading.first.onPressed,
              )
            : null,
        actions: widget.trailing
            .map((a) => IconButton(
                  icon: const Icon(Icons.circle),
                  onPressed: a.onPressed,
                ))
            .toList(growable: false),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: UiKitView(
        viewType: _kNavigationBarViewType,
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
