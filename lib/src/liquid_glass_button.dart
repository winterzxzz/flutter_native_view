import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class _LiquidGlassButtonState extends State<LiquidGlassButton> {
  MethodChannel? _channel;
  Size? _size;

  Map<String, dynamic> _params() {
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

  Future<void> _onCreated(int id) async {
    final MethodChannel channel = MethodChannel('$_kButtonViewType/$id');
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onPressed') widget.onPressed?.call();
      return null;
    });
    _channel = channel;
    await _applySize(channel.invokeMapMethod<String, dynamic>('getIntrinsicSize'));
  }

  Future<void> _applySize(Future<Map<String, dynamic>?> call) async {
    final Map<String, dynamic>? res = await call;
    if (res != null && mounted) {
      setState(() {
        _size = Size((res['width'] as num).toDouble(), (res['height'] as num).toDouble());
      });
    }
  }

  @override
  void didUpdateWidget(LiquidGlassButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.label != widget.label ||
        oldWidget.leadingSymbol != widget.leadingSymbol ||
        oldWidget.trailingSymbol != widget.trailingSymbol ||
        oldWidget.tint != widget.tint ||
        oldWidget.labelColor != widget.labelColor ||
        oldWidget.borderRadius != widget.borderRadius ||
        oldWidget.interactive != widget.interactive ||
        (oldWidget.onPressed == null) != (widget.onPressed == null)) {
      _applySize(_channel?.invokeMapMethod<String, dynamic>('updateConfig', _params()) ??
          Future<Map<String, dynamic>?>.value());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return FilledButton(
        onPressed: widget.onPressed,
        child: Text(widget.label),
      );
    }

    final Size size = _size ?? const Size(120, 48);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: UiKitView(
        viewType: _kButtonViewType,
        creationParams: _params(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onCreated,
        // Tap claim so the down→up sequence reaches the native button and the
        // interactive glass settles back after release.
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<TapGestureRecognizer>(TapGestureRecognizer.new),
        },
      ),
    );
  }
}
