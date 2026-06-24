import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String _kIconButtonViewType = 'flutter_native_view/glass_icon_button';

class LiquidGlassIconButton extends StatefulWidget {
  const LiquidGlassIconButton({
    super.key,
    required this.sfSymbol,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 20,
    this.tint,
    this.borderRadius,
    this.interactive = true,
  });

  /// SF Symbol name for the icon (e.g. "heart", "star.fill").
  final String sfSymbol;

  /// Called on tap. When `null`, the button is disabled.
  final VoidCallback? onPressed;

  /// Overall button size (width = height). Defaults to 44.
  final double size;

  /// Icon size inside the button. Defaults to 20.
  final double iconSize;

  /// Optional glass tint color.
  final Color? tint;

  /// Corner radius. When `null`, uses a circle (Capsule).
  final double? borderRadius;

  /// Whether the iOS 26 glass reacts to touch.
  final bool interactive;

  @override
  State<LiquidGlassIconButton> createState() => _LiquidGlassIconButtonState();
}

class _LiquidGlassIconButtonState extends State<LiquidGlassIconButton> {
  MethodChannel? _channel;
  Size? _size;

  Map<String, dynamic> _params() => <String, dynamic>{
        'sfSymbol': widget.sfSymbol,
        'size': widget.size,
        'iconSize': widget.iconSize,
        'tint': widget.tint?.toARGB32(),
        'cornerRadius': widget.borderRadius,
        'interactive': widget.interactive,
      };

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
