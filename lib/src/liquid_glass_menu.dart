import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_style.dart';

const String _kMenuViewType = 'liquid_glass_native/menu';

/// A typed native menu item.
@immutable
final class LiquidGlassMenuItem<T> {
  const LiquidGlassMenuItem({
    required this.value,
    required this.label,
    this.symbol,
    this.enabled = true,
  }) : assert(label.length > 0);

  final T value;
  final String label;
  final LiquidGlassSymbol? symbol;
  final bool enabled;
}

/// A native pull-down menu that returns typed Dart values.
class LiquidGlassMenu<T> extends StatefulWidget {
  const LiquidGlassMenu({
    super.key,
    required this.label,
    required this.items,
    required this.onSelected,
    this.symbol,
    this.style,
    this.controlStyle,
    this.semanticLabel,
  }) : assert(label.length > 0),
       assert(items.length > 0);

  final String label;
  final List<LiquidGlassMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final LiquidGlassSymbol? symbol;
  final LiquidGlassStyle? style;
  final LiquidGlassControlStyle? controlStyle;
  final String? semanticLabel;

  @override
  State<LiquidGlassMenu<T>> createState() => _LiquidGlassMenuState<T>();
}

class _LiquidGlassMenuState<T> extends State<LiquidGlassMenu<T>>
    with GlassPlatformViewMixin<LiquidGlassMenu<T>> {
  @override
  String get glassViewType => _kMenuViewType;

  @override
  bool get measuresSize => true;

  @override
  Map<String, Object?> buildParams() {
    final LiquidGlassStyle glass = resolveGlassStyle(context, widget.style);
    final LiquidGlassControlStyle control = resolveControlStyle(
      context,
      widget.controlStyle,
    );
    return <String, Object?>{
      'label': widget.label,
      'symbol': widget.symbol?.name,
      'enabled': widget.onSelected != null,
      'accessibilityLabel': widget.semanticLabel,
      'items': widget.items
          .map(
            (LiquidGlassMenuItem<T> item) => <String, Object?>{
              'label': item.label,
              'symbol': item.symbol?.name,
              'enabled': item.enabled,
            },
          )
          .toList(growable: false),
      ...encodeStyles(glass, control),
    };
  }

  @override
  Future<Object?> handleCall(MethodCall call) async {
    if (call.method == 'onSelected' && call.arguments is num) {
      final int index = (call.arguments as num).toInt();
      if (index >= 0 && index < widget.items.length) {
        widget.onSelected?.call(widget.items[index].value);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final LiquidGlassStyle glass = resolveGlassStyle(context, widget.style);
    final LiquidGlassControlStyle control = resolveControlStyle(
      context,
      widget.controlStyle,
    );
    if (!isGlassPlatform) {
      return applyFallbackControlStyle(
        controlStyle: control,
        enabled: widget.onSelected != null,
        child: PopupMenuButton<int>(
          enabled: widget.onSelected != null,
          onSelected: (int index) =>
              widget.onSelected?.call(widget.items[index].value),
          color: glass.tint,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
            for (var index = 0; index < widget.items.length; index++)
              PopupMenuItem<int>(
                value: index,
                enabled: widget.items[index].enabled,
                child: Row(
                  children: <Widget>[
                    if (widget.items[index].symbol?.fallbackIcon
                        case final IconData icon) ...[
                      Icon(icon, color: control.foregroundColor),
                      const SizedBox(width: 8),
                    ],
                    Text(widget.items[index].label),
                  ],
                ),
              ),
          ],
          child: Semantics(
            label: widget.semanticLabel,
            button: true,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: glass.tint?.withValues(
                  alpha: glass.variant == LiquidGlassVariant.clear
                      ? 0.08
                      : 0.18,
                ),
                shape: fallbackOutlinedBorder(glass.shape),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: control.size.minimumDimension,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (widget.symbol?.fallbackIcon
                          case final IconData icon) ...[
                        Icon(icon, color: control.foregroundColor),
                        const SizedBox(width: 8),
                      ],
                      Text(widget.label),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return glassView(
      estimatedSize: Size(120, control.size.minimumDimension),
      gesture: GlassGesture.tap,
    );
  }
}
