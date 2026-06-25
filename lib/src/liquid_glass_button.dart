import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_theme.dart';

const String _kButtonViewType = 'flutter_native_view/glass_button';

/// A button rendered by native SwiftUI with authentic Apple Liquid Glass on
/// iOS 26+. On non-iOS platforms it falls back to a Material [FilledButton].
///
/// The label is rendered natively, so the glass material wraps real content —
/// this is what makes it look like the system glass rather than a flat overlay.
class LiquidGlassButton extends StatefulWidget {
  const LiquidGlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingSymbol,
    this.trailingSymbol,
    this.tint,
    this.labelColor,
    this.borderRadius,
    this.interactive,
  });

  /// A more prominent variant with a larger rounded shape.
  factory LiquidGlassButton.heading({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    String? leadingSymbol,
    String? trailingSymbol,
    Color? tint,
    Color? labelColor,
    double borderRadius = 28,
    bool? interactive,
  }) {
    return LiquidGlassButton(
      key: key,
      label: label,
      onPressed: onPressed,
      leadingSymbol: leadingSymbol,
      trailingSymbol: trailingSymbol,
      tint: tint,
      labelColor: labelColor,
      borderRadius: borderRadius,
      interactive: interactive,
    );
  }

  /// Button title text, rendered natively on iOS.
  final String label;

  /// Optional SF Symbol shown before the label (prefix icon).
  final String? leadingSymbol;

  /// Optional SF Symbol shown after the label (suffix icon).
  final String? trailingSymbol;

  /// Called on tap. When `null`, the button is disabled.
  final VoidCallback? onPressed;

  /// Optional glass tint color. Tints the glass material, not the label.
  /// Falls back to the [LiquidGlassTheme] tint when `null`.
  final Color? tint;

  /// Optional label text color. Falls back to the [LiquidGlassTheme] label
  /// color, otherwise white on iOS glass.
  final Color? labelColor;

  /// Optional corner radius. When `null`, falls back to the
  /// [LiquidGlassTheme] value, otherwise the native button is a capsule.
  final double? borderRadius;

  /// Whether the iOS 26 glass reacts to touch. When `null`, falls back to the
  /// [LiquidGlassTheme] value, otherwise `true`.
  final bool? interactive;

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with GlassPlatformViewMixin<LiquidGlassButton> {
  @override
  String get glassViewType => _kButtonViewType;

  @override
  bool get measuresSize => true;

  @override
  Map<String, dynamic> buildParams() {
    final LiquidGlassThemeData t = LiquidGlassTheme.of(context);
    return <String, dynamic>{
      'title': widget.label,
      'leadingSymbol': widget.leadingSymbol,
      'trailingSymbol': widget.trailingSymbol,
      'tint': (widget.tint ?? t.tint)?.toARGB32(),
      'labelColor': (widget.labelColor ?? t.labelColor)?.toARGB32(),
      'cornerRadius': widget.borderRadius ?? t.borderRadius,
      'interactive': widget.interactive ?? t.interactive ?? true,
      'respectAccessibility': t.respectAccessibility,
      'enabled': widget.onPressed != null,
    };
  }

  @override
  Future<dynamic> handleCall(MethodCall call) async {
    if (call.method == 'onPressed') widget.onPressed?.call();
    return null;
  }

  // Approximate the native button size from the label up front so the view
  // opens at roughly its final size. Without this it starts at a hardcoded
  // placeholder and visibly resizes once Swift reports the real size, which
  // reflows the surrounding layout on first paint.
  Size _estimatedSize() {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: widget.label,
        // Matches the native label font (.system(size: 17, weight: .semibold)).
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    const double iconWidth = 20; // SF Symbol at ~16pt + slack
    const double iconSpacing = 6; // HStack spacing
    const double hPadding = 40; // 20 leading + 20 trailing
    const double vPadding = 24; // 12 top + 12 bottom
    double width = tp.width + hPadding;
    if (widget.leadingSymbol != null) width += iconWidth + iconSpacing;
    if (widget.trailingSymbol != null) width += iconWidth + iconSpacing;
    return Size(width.ceilToDouble(), (tp.height + vPadding).ceilToDouble());
  }

  @override
  void didUpdateWidget(LiquidGlassButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncConfig();
  }

  @override
  Widget build(BuildContext context) {
    if (!isGlassPlatform) {
      return FilledButton(
        onPressed: widget.onPressed,
        child: Text(widget.label),
      );
    }
    return glassView(estimatedSize: _estimatedSize());
  }
}
