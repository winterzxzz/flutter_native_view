import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_theme.dart';

const String _kIconButtonViewType = 'flutter_native_view/glass_icon_button';

/// A compact, icon-only button rendered by native SwiftUI with authentic Apple
/// Liquid Glass on iOS 26+. On non-iOS platforms it falls back to a Material
/// [IconButton.filled].
///
/// The icon is an SF Symbol drawn natively, so the glass material wraps real
/// content. Use it for circular glass actions such as a favorite or close
/// button.
class LiquidGlassIconButton extends StatefulWidget {
  const LiquidGlassIconButton({
    super.key,
    required this.sfSymbol,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 20,
    this.tint,
    this.iconColor,
    this.borderRadius,
    this.interactive,
    this.fallbackIcon = Icons.star,
  });

  /// SF Symbol name for the icon (e.g. "heart", "star.fill").
  final String sfSymbol;

  /// Called on tap. When `null`, the button is disabled.
  final VoidCallback? onPressed;

  /// Overall button size (width = height). Defaults to 44.
  final double size;

  /// Icon size inside the button. Defaults to 20.
  final double iconSize;

  /// Optional glass tint color. Falls back to the [LiquidGlassTheme] tint.
  final Color? tint;

  /// Optional icon foreground color. When set, overrides the tint color used
  /// for the symbol itself while the glass tint still controls the background.
  /// Falls back to the [LiquidGlassTheme] icon color.
  final Color? iconColor;

  /// Corner radius. When `null`, falls back to the [LiquidGlassTheme] value,
  /// otherwise a circle (Capsule).
  final double? borderRadius;

  /// Whether the iOS 26 glass reacts to touch. When `null`, falls back to the
  /// [LiquidGlassTheme] value, otherwise `true`.
  final bool? interactive;

  /// Material icon used on non-iOS platforms, where [sfSymbol] cannot render.
  /// Defaults to [Icons.star] — set it so the fallback matches your action.
  final IconData fallbackIcon;

  @override
  State<LiquidGlassIconButton> createState() => _LiquidGlassIconButtonState();
}

class _LiquidGlassIconButtonState extends State<LiquidGlassIconButton>
    with GlassPlatformViewMixin<LiquidGlassIconButton> {
  @override
  String get glassViewType => _kIconButtonViewType;

  @override
  bool get measuresSize => true;

  @override
  Map<String, dynamic> buildParams() {
    final LiquidGlassThemeData t = LiquidGlassTheme.of(context);
    return <String, dynamic>{
      'sfSymbol': widget.sfSymbol,
      'size': widget.size,
      'iconSize': widget.iconSize,
      'tint': (widget.tint ?? t.tint)?.toARGB32(),
      'iconColor': (widget.iconColor ?? t.iconColor)?.toARGB32(),
      'cornerRadius': widget.borderRadius ?? t.borderRadius,
      'interactive': widget.interactive ?? t.interactive ?? true,
      'respectAccessibility': t.respectAccessibility,
    };
  }

  @override
  Future<dynamic> handleCall(MethodCall call) async {
    if (call.method == 'onPressed') widget.onPressed?.call();
    return null;
  }

  @override
  void didUpdateWidget(LiquidGlassIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncConfig();
  }

  @override
  Widget build(BuildContext context) {
    if (!isGlassPlatform) {
      return IconButton.filled(
        onPressed: widget.onPressed,
        iconSize: widget.iconSize,
        color: widget.iconColor,
        icon: Icon(widget.fallbackIcon),
      );
    }
    return glassView(estimatedSize: Size(widget.size, widget.size));
  }
}
