import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String _kTabBarViewType = 'flutter_native_view/glass_tab_bar';

/// A native horizontal glass tab bar with Liquid Glass styling on iOS 26+.
///
/// Items share one `GlassEffectContainer` so the glass surface is continuous.
/// On non-iOS platforms it falls back to a Material [NavigationBar].
class LiquidGlassTabBar extends StatefulWidget {
  const LiquidGlassTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<TabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<LiquidGlassTabBar> createState() => _LiquidGlassTabBarState();
}

/// A single tab item inside [LiquidGlassTabBar].
class TabItem {
  const TabItem({
    required this.label,
    this.sfSymbol,
  });

  final String label;
  final String? sfSymbol;
}

class _LiquidGlassTabBarState extends State<LiquidGlassTabBar> {
  MethodChannel? _channel;

  List<Map<String, dynamic>> _itemsJson() => widget.items
      .map((item) => <String, dynamic>{
            'label': item.label,
            'sfSymbol': item.sfSymbol,
          })
      .toList(growable: false);

  Map<String, dynamic> _params() => <String, dynamic>{
        'items': _itemsJson(),
        'currentIndex': widget.currentIndex,
      };

  void _onCreated(int id) {
    final MethodChannel channel = MethodChannel('$_kTabBarViewType/$id');
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onIndexChanged') {
        widget.onTap(call.arguments as int);
      }
      return null;
    });
    _channel = channel;
  }

  @override
  void didUpdateWidget(LiquidGlassTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _channel?.invokeMethod<void>('updateConfig', _params());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return NavigationBar(
        selectedIndex: widget.currentIndex,
        onDestinationSelected: widget.onTap,
        destinations: widget.items
            .map((item) => NavigationDestination(
                  icon: item.sfSymbol != null
                      ? Icon(Icons.abc)
                      : const Icon(Icons.circle),
                  label: item.label,
                ))
            .toList(growable: false),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: UiKitView(
        viewType: _kTabBarViewType,
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
