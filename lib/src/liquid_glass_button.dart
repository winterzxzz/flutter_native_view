// The label and icon constructors initialize a nullable union field from a
// deliberately non-null parameter; initializing formals would weaken the
// public contract.
// ignore_for_file: prefer_initializing_formals

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_style.dart';

const String _kButtonViewType = 'liquid_glass_native/button';

/// Visual prominence of a native Liquid Glass button.
enum LiquidGlassButtonProminence { standard, prominent }

/// A native SwiftUI Liquid Glass button with real native label content.
class LiquidGlassButton extends StatefulWidget {
  const LiquidGlassButton({
    super.key,
    required String label,
    required this.onPressed,
    this.leadingSymbol,
    this.trailingSymbol,
    this.style,
    this.controlStyle,
    this.semanticLabel,
  }) : label = label,
       iconOnlySymbol = null,
       prominence = LiquidGlassButtonProminence.standard,
       assert(label.length > 0);

  /// A system prominent glass button on iOS 26+.
  const LiquidGlassButton.prominent({
    super.key,
    required String label,
    required this.onPressed,
    this.leadingSymbol,
    this.trailingSymbol,
    this.style,
    this.controlStyle,
    this.semanticLabel,
  }) : label = label,
       iconOnlySymbol = null,
       prominence = LiquidGlassButtonProminence.prominent,
       assert(label.length > 0);

  /// An icon-only native button.
  const LiquidGlassButton.icon({
    super.key,
    required LiquidGlassSymbol symbol,
    required this.onPressed,
    this.style,
    this.controlStyle,
    this.semanticLabel,
  }) : label = null,
       iconOnlySymbol = symbol,
       leadingSymbol = null,
       trailingSymbol = null,
       prominence = LiquidGlassButtonProminence.standard;

  final String? label;
  final LiquidGlassSymbol? iconOnlySymbol;
  final LiquidGlassSymbol? leadingSymbol;
  final LiquidGlassSymbol? trailingSymbol;
  final VoidCallback? onPressed;
  final LiquidGlassButtonProminence prominence;
  final LiquidGlassStyle? style;
  final LiquidGlassControlStyle? controlStyle;

  /// Accessibility label used when visible text is absent or insufficient.
  final String? semanticLabel;

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
  Map<String, Object?> buildParams() {
    final LiquidGlassStyle glass = resolveGlassStyle(context, widget.style);
    final LiquidGlassControlStyle control = resolveControlStyle(
      context,
      widget.controlStyle,
    );
    return <String, Object?>{
      'label': widget.label,
      'iconOnlySymbol': widget.iconOnlySymbol?.name,
      'leadingSymbol': widget.leadingSymbol?.name,
      'trailingSymbol': widget.trailingSymbol?.name,
      'prominence': widget.prominence.name,
      'enabled': widget.onPressed != null,
      'accessibilityLabel': widget.semanticLabel,
      ...encodeStyles(glass, control),
    };
  }

  @override
  Future<Object?> handleCall(MethodCall call) async {
    if (call.method == 'onPressed') widget.onPressed?.call();
    return null;
  }

  Size _estimate(LiquidGlassControlStyle control) {
    final double dimension = control.size.minimumDimension;
    if (widget.iconOnlySymbol != null) return Size.square(dimension);
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: widget.label,
        style: TextStyle(
          fontSize: switch (control.size) {
            LiquidGlassControlSize.compact => 15,
            LiquidGlassControlSize.regular => 17,
            LiquidGlassControlSize.large => 19,
          },
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    var width = painter.width + dimension;
    if (widget.leadingSymbol != null) width += 24;
    if (widget.trailingSymbol != null) width += 24;
    return Size(width.ceilToDouble(), dimension);
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
        child: _fallback(glass, control),
        controlStyle: control,
        enabled: widget.onPressed != null,
      );
    }
    return glassView(estimatedSize: _estimate(control));
  }

  Widget _fallback(LiquidGlassStyle glass, LiquidGlassControlStyle control) {
    final double dimension = control.size.minimumDimension;
    final ButtonStyle buttonStyle = FilledButton.styleFrom(
      foregroundColor: control.foregroundColor,
      backgroundColor: glass.tint,
      minimumSize: Size(dimension, dimension),
      disabledForegroundColor: control.foregroundColor?.withValues(
        alpha: control.disabledOpacity,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: fallbackBorderRadius(glass.shape),
      ),
    );
    if (widget.iconOnlySymbol case final LiquidGlassSymbol symbol) {
      return Semantics(
        label: widget.semanticLabel,
        button: true,
        child: IconButton.filled(
          onPressed: widget.onPressed,
          icon: Icon(symbol.fallbackIcon ?? Icons.circle_outlined),
          color: control.foregroundColor,
          style: IconButton.styleFrom(
            backgroundColor: glass.tint,
            minimumSize: Size.square(dimension),
            shape: RoundedRectangleBorder(
              borderRadius: fallbackBorderRadius(glass.shape),
            ),
          ),
        ),
      );
    }
    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.leadingSymbol?.fallbackIcon case final IconData icon) ...[
          Icon(icon),
          const SizedBox(width: 8),
        ],
        Text(widget.label!),
        if (widget.trailingSymbol?.fallbackIcon case final IconData icon) ...[
          const SizedBox(width: 8),
          Icon(icon),
        ],
      ],
    );
    final Widget button =
        widget.prominence == LiquidGlassButtonProminence.prominent
        ? FilledButton(
            onPressed: widget.onPressed,
            style: buttonStyle,
            child: content,
          )
        : FilledButton.tonal(
            onPressed: widget.onPressed,
            style: buttonStyle,
            child: content,
          );
    return Semantics(label: widget.semanticLabel, child: button);
  }
}
