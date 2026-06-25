import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'liquid_glass_theme.dart';

const String _kTabBarViewType = 'flutter_native_view/glass_tab_bar';

/// A native iOS tab bar backed by a real `UITabBarController`, so the OS draws
/// the authentic Liquid Glass bar (floating glass, minimize-on-scroll, search
/// accessory) on iOS 26+ — not a reimplementation.
///
/// Each tab's screen content is rendered by Flutter; only the system tab bar
/// chrome is native. Pin this widget to the screen's bottom edge.
/// On non-iOS platforms it falls back to a Material [NavigationBar].
class LiquidGlassTabBar extends StatefulWidget {
  const LiquidGlassTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.accessorySymbol,
    this.onAccessoryTap,
    this.tint,
    this.scrollController,
  });

  final List<TabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Optional controller of the currently visible scrollable content.
  ///
  /// When provided, scroll offsets are forwarded to the native bar so iOS 26's
  /// `tabBarMinimizeBehavior` minimizes the bar on scroll-down and expands on
  /// scroll-up — the native behavior can't observe Flutter's scroll otherwise.
  final ScrollController? scrollController;

  /// Accent color for the selected tab and its highlight pill.
  /// Defaults to white. Unselected items are dimmed white.
  final Color? tint;

  /// SF Symbol for a detached trailing accessory button (e.g. `magnifyingglass`).
  ///
  /// Renders as a separate glass circle beside the tab capsule, like the
  /// search button in Apple News. Null hides it.
  final String? accessorySymbol;

  /// Called when the accessory button is tapped.
  final VoidCallback? onAccessoryTap;

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
        'accessorySymbol': widget.accessorySymbol,
        'tint': (widget.tint ?? LiquidGlassTheme.of(context).tint)?.toARGB32(),
        'respectAccessibility': LiquidGlassTheme.of(context).respectAccessibility,
      };

  void _onCreated(int id) {
    final MethodChannel channel = MethodChannel('$_kTabBarViewType/$id');
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onIndexChanged':
          widget.onTap(call.arguments as int);
        case 'onAccessoryTap':
          widget.onAccessoryTap?.call();
      }
      return null;
    });
    _channel = channel;
  }

  void _onScroll() {
    final ScrollController? c = widget.scrollController;
    if (c == null || !c.hasClients) return;
    _channel?.invokeMethod<void>('setScrollOffset', c.position.pixels);
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  @override
  void didUpdateWidget(LiquidGlassTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
    if (oldWidget.currentIndex != widget.currentIndex ||
        oldWidget.accessorySymbol != widget.accessorySymbol ||
        oldWidget.tint != widget.tint) {
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

    // Backed by a real native UITabBarController, so it needs room for the
    // system bar plus the bottom safe-area region. Pin this to the screen's
    // bottom edge so the OS resolves the safe-area inset and floats the glass
    // bar above the home indicator.
    return SizedBox(
      width: double.infinity,
      height: 100,
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
