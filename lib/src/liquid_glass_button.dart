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

  // Debug counters: how many times this button has rebuilt / been resized by
  // the native side. Only active in debug builds; remove once flicker is tuned.
  int _buildCount = 0;
  int _resizeCount = 0;

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
    if (res == null || !mounted) return;
    final Size next =
        Size((res['width'] as num).toDouble(), (res['height'] as num).toDouble());
    // Skip the rebuild when the measured size is unchanged. A counter label like
    // "Tapped 0 times" → "Tapped 1 times" keeps the same width, so re-running
    // setState here would needlessly repaint the platform view (visible flash).
    if (_size == next) return;
    if (kDebugMode) {
      _resizeCount++;
      debugPrint('[GlassButton "${widget.label}"] resize #$_resizeCount '
          '$_size -> $next');
    }
    setState(() => _size = next);
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
    if (kDebugMode) {
      _buildCount++;
      debugPrint('[GlassButton "${widget.label}"] build #$_buildCount '
          '(size=${_size == null ? "estimate" : "${_size!.width.toStringAsFixed(0)}x${_size!.height.toStringAsFixed(0)}"})');
    }
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return FilledButton(
        onPressed: widget.onPressed,
        child: Text(widget.label),
      );
    }

    final Size size = _size ?? _estimatedSize();
    // Stay invisible at the estimated size until Swift confirms the real size,
    // then fade in. This hides the placeholder→measured correction entirely so
    // there is no visible pop or resize when the page first appears.
    return AnimatedOpacity(
      opacity: _size == null ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: SizedBox(
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
      ),
    );
  }
}
