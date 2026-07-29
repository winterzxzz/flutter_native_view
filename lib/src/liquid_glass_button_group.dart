import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_button.dart';
import 'liquid_glass_style.dart';

const String _kButtonGroupViewType = 'liquid_glass_native/button_group';

/// One native action inside a [LiquidGlassButtonGroup].
@immutable
final class LiquidGlassButtonItem {
  const LiquidGlassButtonItem({
    required this.id,
    this.label,
    this.symbol,
    this.onPressed,
    this.style,
    this.controlStyle,
    this.semanticLabel,
  }) : assert(id.length > 0),
       assert(label != null || symbol != null);

  /// Stable event and SwiftUI identity. IDs must be unique within a group.
  final String id;
  final String? label;
  final LiquidGlassSymbol? symbol;
  final VoidCallback? onPressed;
  final LiquidGlassStyle? style;
  final LiquidGlassControlStyle? controlStyle;
  final String? semanticLabel;
}

/// Native buttons sharing one platform view and one `GlassEffectContainer`.
class LiquidGlassButtonGroup extends StatefulWidget {
  const LiquidGlassButtonGroup({
    super.key,
    required this.items,
    this.spacing = 8,
    this.style,
    this.controlStyle,
  }) : assert(items.length > 0),
       assert(spacing >= 0 && spacing < double.infinity);

  final List<LiquidGlassButtonItem> items;
  final double spacing;
  final LiquidGlassStyle? style;
  final LiquidGlassControlStyle? controlStyle;

  @override
  State<LiquidGlassButtonGroup> createState() => _LiquidGlassButtonGroupState();
}

class _LiquidGlassButtonGroupState extends State<LiquidGlassButtonGroup>
    with GlassPlatformViewMixin<LiquidGlassButtonGroup> {
  @override
  String get glassViewType => _kButtonGroupViewType;

  @override
  bool get measuresSize => true;

  void _debugValidate() {
    assert(() {
      final Set<String> ids = widget.items
          .map((LiquidGlassButtonItem item) => item.id)
          .toSet();
      if (ids.length != widget.items.length) {
        throw FlutterError('LiquidGlassButtonGroup item IDs must be unique.');
      }
      return true;
    }());
  }

  @override
  Map<String, Object?> buildParams() {
    _debugValidate();
    final LiquidGlassStyle groupGlass = resolveGlassStyle(
      context,
      widget.style,
    );
    final LiquidGlassControlStyle groupControl = resolveControlStyle(
      context,
      widget.controlStyle,
    );
    return <String, Object?>{
      'items': widget.items
          .map((LiquidGlassButtonItem item) {
            final LiquidGlassStyle glass = item.style ?? groupGlass;
            final LiquidGlassControlStyle control =
                item.controlStyle ?? groupControl;
            return <String, Object?>{
              'id': item.id,
              'label': item.label,
              'symbol': item.symbol?.name,
              'enabled': item.onPressed != null,
              'accessibilityLabel': item.semanticLabel,
              ...encodeStyles(glass, control),
            };
          })
          .toList(growable: false),
      'spacing': widget.spacing,
    };
  }

  @override
  Future<Object?> handleCall(MethodCall call) async {
    if (call.method != 'onPressed' || call.arguments is! String) return null;
    final String id = call.arguments as String;
    for (final LiquidGlassButtonItem item in widget.items) {
      if (item.id == id) {
        item.onPressed?.call();
        break;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    _debugValidate();
    if (!isGlassPlatform) {
      return Wrap(
        spacing: widget.spacing,
        runSpacing: widget.spacing,
        children: widget.items
            .map((LiquidGlassButtonItem item) {
              if (item.label == null) {
                return LiquidGlassButton.icon(
                  symbol: item.symbol!,
                  onPressed: item.onPressed,
                  style: item.style ?? widget.style,
                  controlStyle: item.controlStyle ?? widget.controlStyle,
                  semanticLabel: item.semanticLabel,
                );
              }
              return LiquidGlassButton(
                label: item.label!,
                onPressed: item.onPressed,
                leadingSymbol: item.symbol,
                style: item.style ?? widget.style,
                controlStyle: item.controlStyle ?? widget.controlStyle,
                semanticLabel: item.semanticLabel,
              );
            })
            .toList(growable: false),
      );
    }
    return glassView(estimatedSize: const Size(220, 44));
  }
}
