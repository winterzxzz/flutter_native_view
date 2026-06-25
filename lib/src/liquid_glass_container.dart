import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'liquid_glass_theme.dart';

const String _kContainerViewType = 'flutter_native_view/glass_container';

/// A decorative glass panel rendered natively on iOS.
///
/// Provides a Liquid Glass surface that can wrap Flutter content. On iOS 26+
/// it renders authentic Apple glass; on older iOS it uses standard SwiftUI
/// styling; on non-iOS platforms it falls back to a Material [DecoratedBox].
///
/// Provide a [child] to render Flutter content layered on top of the glass
/// surface:
/// ```dart
/// LiquidGlassContainer(
///   child: Padding(
///     padding: EdgeInsets.all(16),
///     child: Text('Content'),
///   ),
/// )
/// ```
class LiquidGlassContainer extends StatefulWidget {
  const LiquidGlassContainer({
    super.key,
    this.tint,
    this.borderRadius,
    this.child,
    this.onPressed,
  });

  /// Optional glass tint color.
  final Color? tint;

  /// Corner radius. When `null`, uses a continuous rounded rectangle with
  /// a default radius of 20.
  final double? borderRadius;

  /// Optional Flutter content rendered on top of the glass surface. The glass
  /// sizes itself to the child; when `null` it expands to fill its parent.
  final Widget? child;

  /// Optional tap callback. When non-null, the native glass renders with
  /// `.interactive()` so the Liquid Glass morph animation fires on tap.
  final VoidCallback? onPressed;

  @override
  State<LiquidGlassContainer> createState() => _LiquidGlassContainerState();
}

class _LiquidGlassContainerState extends State<LiquidGlassContainer> {
  MethodChannel? _channel;

  Map<String, dynamic> _params() {
    final LiquidGlassThemeData t = LiquidGlassTheme.of(context);
    return <String, dynamic>{
      'tint': (widget.tint ?? t.tint)?.toARGB32(),
      'cornerRadius': widget.borderRadius ?? t.borderRadius,
      'respectAccessibility': t.respectAccessibility,
      'interactive': widget.onPressed != null,
    };
  }

  Future<void> _onPlatformViewCreated(int id) async {
    if (widget.onPressed == null) return;
    final MethodChannel ch =
        MethodChannel('flutter_native_view/glass_container/$id');
    ch.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onPressed') widget.onPressed?.call();
      return null;
    });
    _channel = ch;
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LiquidGlassThemeData t = LiquidGlassTheme.of(context);
    final Color? tint = widget.tint ?? t.tint;
    final double radius = widget.borderRadius ?? t.borderRadius ?? 20;
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      final Widget box = DecoratedBox(
        decoration: BoxDecoration(
          color: tint?.withValues(alpha: 0.15) ?? Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: tint?.withValues(alpha: 0.30) ?? Colors.white.withValues(alpha: 0.22),
          ),
        ),
        child: widget.child ?? const SizedBox.expand(),
      );
      if (widget.onPressed == null) return box;
      return GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: box);
    }

    final Set<Factory<OneSequenceGestureRecognizer>> recognizers =
        widget.onPressed != null
            ? <Factory<OneSequenceGestureRecognizer>>{
                Factory<TapGestureRecognizer>(TapGestureRecognizer.new),
              }
            : const <Factory<OneSequenceGestureRecognizer>>{};

    final Widget glass = UiKitView(
      viewType: _kContainerViewType,
      creationParams: _params(),
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onPlatformViewCreated,
      gestureRecognizers: recognizers,
    );

    if (widget.child == null) return glass;

    // Size the glass to the child and layer the content on top.
    // When interactive, the child must not absorb taps — the native glass
    // Button underneath needs them for the liquid-glass morph animation.
    return Stack(
      children: <Widget>[
        Positioned.fill(child: glass),
        if (widget.onPressed != null)
          IgnorePointer(child: widget.child!)
        else
          widget.child!,
      ],
    );
  }
}
