import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final Color? iconColor;

  /// Corner radius. When `null`, falls back to the [LiquidGlassTheme] value,
  /// otherwise a circle (Capsule).
  final double? borderRadius;

  /// Whether the iOS 26 glass reacts to touch. When `null`, falls back to the
  /// [LiquidGlassTheme] value, otherwise `true`.
  final bool? interactive;

  @override
  State<LiquidGlassIconButton> createState() => _LiquidGlassIconButtonState();
}

class _LiquidGlassIconButtonState extends State<LiquidGlassIconButton> {
  MethodChannel? _channel;
  Size? _size;

  Map<String, dynamic> _params() {
    final LiquidGlassThemeData t = LiquidGlassTheme.of(context);
    return <String, dynamic>{
      'sfSymbol': widget.sfSymbol,
      'size': widget.size,
      'iconSize': widget.iconSize,
      'tint': (widget.tint ?? t.tint)?.toARGB32(),
      'iconColor': widget.iconColor?.toARGB32(),
      'cornerRadius': widget.borderRadius ?? t.borderRadius,
      'interactive': widget.interactive ?? t.interactive ?? true,
      'respectAccessibility': t.respectAccessibility,
    };
  }

  Future<void> _onCreated(int id) async {
    final MethodChannel channel = MethodChannel('$_kIconButtonViewType/$id');
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
  void didUpdateWidget(LiquidGlassIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sfSymbol != widget.sfSymbol ||
        oldWidget.size != widget.size ||
        oldWidget.iconSize != widget.iconSize ||
        oldWidget.tint != widget.tint ||
        oldWidget.iconColor != widget.iconColor ||
        oldWidget.borderRadius != widget.borderRadius ||
        oldWidget.interactive != widget.interactive) {
      _applySize(_channel?.invokeMapMethod<String, dynamic>('updateConfig', _params()) ??
          Future<Map<String, dynamic>?>.value());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return IconButton.filled(
        onPressed: widget.onPressed,
        iconSize: widget.iconSize,
        icon: const Icon(Icons.star),
      );
    }

    final Size size = _size ?? Size(widget.size, widget.size);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: UiKitView(
        viewType: _kIconButtonViewType,
        creationParams: _params(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<TapGestureRecognizer>(TapGestureRecognizer.new),
        },
      ),
    );
  }
}
