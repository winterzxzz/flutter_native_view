import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bar_action.dart';

const String _kToolbarViewType = 'flutter_native_view/glass_toolbar';

/// A bottom toolbar with Liquid Glass styling on iOS 26+.
///
/// Similar to [LiquidGlassNavigationBar] but positioned at the bottom.
/// On non-iOS platforms it falls back to a Material [BottomAppBar].
class LiquidGlassToolbar extends StatefulWidget {
  const LiquidGlassToolbar({
    super.key,
    this.actions = const [],
  });

  final List<BarAction> actions;

  @override
  State<LiquidGlassToolbar> createState() => _LiquidGlassToolbarState();
}

class _LiquidGlassToolbarState extends State<LiquidGlassToolbar> {
  Map<String, VoidCallback> get _callbacks => {
        for (final a in widget.actions) a.id: a.onPressed ?? () {},
      };

  Map<String, dynamic> _params() => <String, dynamic>{
        'actions': widget.actions
            .map((a) => <String, dynamic>{
                  'id': a.id,
                  'sfSymbol': a.sfSymbol,
                  'tint': a.tint?.toARGB32(),
                  'iconColor': a.iconColor?.toARGB32(),
                })
            .toList(growable: false),
      };

  void _onCreated(int id) {
    MethodChannel('$_kToolbarViewType/$id').setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onAction') {
        final String? actionId = call.arguments as String?;
        if (actionId != null) _callbacks[actionId]?.call();
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widget.actions
              .map((a) => IconButton(
                    icon: const Icon(Icons.circle),
                    onPressed: a.onPressed,
                  ))
              .toList(growable: false),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: UiKitView(
        viewType: _kToolbarViewType,
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
