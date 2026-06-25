import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bar_action.dart';
import 'glass_platform_view.dart';

const String _kToolbarViewType = 'flutter_native_view/glass_toolbar';

/// A bottom toolbar with Liquid Glass styling on iOS 26+.
///
/// Similar to [LiquidGlassNavigationBar] but positioned at the bottom.
/// On non-iOS platforms it falls back to a Material [BottomAppBar].
class LiquidGlassToolbar extends StatefulWidget {
  const LiquidGlassToolbar({
    super.key,
    this.actions = const <BarAction>[],
    this.height = 50,
  });

  final List<BarAction> actions;

  /// Bar height. Defaults to 50. Width always fills the parent.
  final double height;

  @override
  State<LiquidGlassToolbar> createState() => _LiquidGlassToolbarState();
}

class _LiquidGlassToolbarState extends State<LiquidGlassToolbar>
    with GlassPlatformViewMixin<LiquidGlassToolbar> {
  @override
  String get glassViewType => _kToolbarViewType;

  Map<String, VoidCallback> get _callbacks => <String, VoidCallback>{
        for (final BarAction a in widget.actions) a.id: a.onPressed ?? () {},
      };

  @override
  Map<String, dynamic> buildParams() => <String, dynamic>{
        'actions': widget.actions
            .map((BarAction a) => <String, dynamic>{
                  'id': a.id,
                  'sfSymbol': a.sfSymbol,
                  'tint': a.tint?.toARGB32(),
                  'iconColor': a.iconColor?.toARGB32(),
                })
            .toList(growable: false),
      };

  @override
  Future<dynamic> handleCall(MethodCall call) async {
    if (call.method == 'onAction') {
      final String? actionId = call.arguments as String?;
      if (actionId != null) _callbacks[actionId]?.call();
    }
    return null;
  }

  @override
  void didUpdateWidget(LiquidGlassToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncConfig();
  }

  @override
  Widget build(BuildContext context) {
    if (!isGlassPlatform) {
      return BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widget.actions
              .map((BarAction a) => IconButton(
                    icon: const Icon(Icons.circle),
                    onPressed: a.onPressed,
                  ))
              .toList(growable: false),
        ),
      );
    }
    return glassView(width: double.infinity, height: widget.height);
  }
}
