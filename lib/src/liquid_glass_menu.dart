import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
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
    this.iconColor,
  });

  /// Text shown on the menu button itself.
  final String label;

  /// The selectable rows presented when the menu opens.
  final List<MenuItem> items;

  /// Called with the [MenuItem.id] of the tapped row.
  final ValueChanged<String> onSelected;

  /// Optional SF Symbol shown on the button before the label.
  final String? sfSymbol;

  /// Optional glass tint color. Falls back to the [LiquidGlassTheme] tint.
  final Color? tint;

  /// Optional icon/label foreground color. When set, overrides the tint for
  /// the button's symbol and text so they can be white regardless of tint.
  /// Falls back to the [LiquidGlassTheme] icon color.
  final Color? iconColor;

  @override
  State<LiquidGlassMenu> createState() => _LiquidGlassMenuState();
}

class _LiquidGlassMenuState extends State<LiquidGlassMenu>
    with GlassPlatformViewMixin<LiquidGlassMenu> {
  @override
  String get glassViewType => _kMenuViewType;

  @override
  bool get measuresSize => true;

  @override
  Map<String, dynamic> buildParams() {
    final LiquidGlassThemeData t = LiquidGlassTheme.of(context);
    return <String, dynamic>{
      'label': widget.label,
      'sfSymbol': widget.sfSymbol ?? '',
      'items': widget.items
          .map((MenuItem m) => <String, dynamic>{
                'id': m.id,
                'title': m.title,
                'sfSymbol': m.sfSymbol ?? '',
              })
          .toList(),
      'tint': (widget.tint ?? t.tint)?.toARGB32(),
      'iconColor': (widget.iconColor ?? t.iconColor)?.toARGB32(),
      'respectAccessibility': t.respectAccessibility,
    };
  }

  @override
  Future<dynamic> handleCall(MethodCall call) async {
    if (call.method == 'onSelected') {
      widget.onSelected(call.arguments as String);
    }
    return null;
  }

  @override
  void didUpdateWidget(LiquidGlassMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncConfig();
  }

  @override
  Widget build(BuildContext context) {
    if (!isGlassPlatform) {
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
    return glassView(estimatedSize: const Size(100, 44));
  }
}
