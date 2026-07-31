import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

/// Asset key for the bundled refraction shader (declared under `flutter:
/// shaders:` in this package's pubspec).
const String _kShaderAsset =
    'packages/liquid_glass_native/shaders/liquid_glass.frag';

/// Visual configuration for a [LiquidGlass] lens.
///
/// All distances are in logical pixels. Defaults aim for a soft, believable
/// glass; bump [refraction] and [chromaticAberration] for a more exaggerated
/// look.
@immutable
class LiquidGlassStyle {
  const LiquidGlassStyle({
    this.borderRadius = 28,
    this.tint = Colors.white,
    this.tintOpacity = 0.10,
    this.refraction = 18,
    this.chromaticAberration = 3,
    this.highlight = 0.25,
    this.fallbackBlurSigma = 12,
  });

  /// Corner radius of the rounded-rect lens.
  final double borderRadius;

  /// Glass tint colour (alpha is taken from [tintOpacity], not the colour).
  final Color tint;

  /// How strongly [tint] is mixed over the refracted backdrop, 0..1.
  final double tintOpacity;

  /// Edge bend strength — how far the rim displaces the backdrop sample.
  final double refraction;

  /// Per-channel split at the rim, for a subtle prism fringe.
  final double chromaticAberration;

  /// Specular rim brightness, 0..1.
  final double highlight;

  /// Blur used by the non-Impeller / pre-capture fallback frosted look.
  final double fallbackBlurSigma;

  LiquidGlassStyle copyWith({
    double? borderRadius,
    Color? tint,
    double? tintOpacity,
    double? refraction,
    double? chromaticAberration,
    double? highlight,
    double? fallbackBlurSigma,
  }) {
    return LiquidGlassStyle(
      borderRadius: borderRadius ?? this.borderRadius,
      tint: tint ?? this.tint,
      tintOpacity: tintOpacity ?? this.tintOpacity,
      refraction: refraction ?? this.refraction,
      chromaticAberration: chromaticAberration ?? this.chromaticAberration,
      highlight: highlight ?? this.highlight,
      fallbackBlurSigma: fallbackBlurSigma ?? this.fallbackBlurSigma,
    );
  }
}

/// Shared state between a [LiquidGlassView] and the [LiquidGlass] lenses inside
/// it: the loaded shader program and the most recent backdrop snapshot.
class _GlassController extends ChangeNotifier {
  _GlassController(this.contentKey);

  /// Identifies the captured content's render box so a lens can compute its
  /// offset within the backdrop snapshot.
  final GlobalKey contentKey;

  ui.FragmentProgram? program;
  ui.Image? _image;
  double dpr = 1;

  ui.Image? get image => _image;

  void setProgram(ui.FragmentProgram p) {
    program = p;
    notifyListeners();
  }

  /// Stores a new backdrop snapshot. The previous one is released. Notification
  /// is deferred to after the frame so lenses (which paint during the same
  /// frame and already read [image] directly) are not asked to repaint
  /// mid-paint; the listener exists only to refresh lenses on later frames.
  void setImage(ui.Image next, double pixelRatio) {
    final ui.Image? old = _image;
    _image = next;
    dpr = pixelRatio;
    if (old != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }

  @override
  void dispose() {
    _image?.dispose();
    _image = null;
    super.dispose();
  }
}

class _GlassScope extends InheritedWidget {
  const _GlassScope({required this.controller, required super.child});

  final _GlassController controller;

  static _GlassController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_GlassScope>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(_GlassScope oldWidget) =>
      controller != oldWidget.controller;
}

/// Wraps the content that [LiquidGlass] lenses refract.
///
/// Every frame it captures its subtree to a texture (via Impeller's sampler)
/// and shares it with descendant lenses. Place your background and the glass
/// lenses inside a single `Stack` under one [LiquidGlassView]:
///
/// ```dart
/// LiquidGlassView(
///   child: Stack(children: [
///     backgroundContent,
///     Positioned(left: 40, top: 80, child: LiquidGlass(child: Icon(...))),
///   ]),
/// )
/// ```
class LiquidGlassView extends StatefulWidget {
  const LiquidGlassView({super.key, required this.child});

  final Widget child;

  @override
  State<LiquidGlassView> createState() => _LiquidGlassViewState();
}

class _LiquidGlassViewState extends State<LiquidGlassView> {
  final GlobalKey _contentKey = GlobalKey();
  late final _GlassController _controller = _GlassController(_contentKey);

  @override
  void initState() {
    super.initState();
    ui.FragmentProgram.fromAsset(_kShaderAsset)
        .then((p) {
      if (mounted) _controller.setProgram(p);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double dpr = MediaQuery.of(context).devicePixelRatio;
    return _GlassScope(
      controller: _controller,
      child: AnimatedSampler(
        (ui.Image image, Size size, Canvas canvas) {
          // Keep a handle alive for lenses painted later this frame.
          _controller.setImage(image.clone(), dpr);
          // Draw the captured content normally so the view looks unchanged.
          canvas.drawImageRect(
            image,
            Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
            Offset.zero & size,
            Paint(),
          );
        },
        child: KeyedSubtree(key: _contentKey, child: widget.child),
      ),
    );
  }
}

/// A liquid-glass lens that refracts the [LiquidGlassView] content behind it
/// and renders [child] (an icon, label, anything) clipped on top.
///
/// Must be a descendant of a [LiquidGlassView]. Without one — or before the
/// first backdrop capture — it renders a frosted blur+tint fallback.
class LiquidGlass extends StatefulWidget {
  const LiquidGlass({
    super.key,
    this.child,
    this.width,
    this.height,
    this.style = const LiquidGlassStyle(),
    this.onTap,
  });

  /// Foreground content drawn on top of the glass, clipped to its shape.
  final Widget? child;

  /// Optional fixed size. When null the lens sizes to [child].
  final double? width;
  final double? height;

  final LiquidGlassStyle style;

  /// When non-null, the lens is tappable and plays a brief press ripple.
  final VoidCallback? onTap;

  @override
  State<LiquidGlass> createState() => _LiquidGlassState();
}

class _LiquidGlassState extends State<LiquidGlass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
    reverseDuration: const Duration(milliseconds: 260),
  );

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _down(_) => _press.forward();
  void _up(_) => _press.reverse();

  @override
  Widget build(BuildContext context) {
    final _GlassController? controller = _GlassScope.maybeOf(context);

    Widget lens = AnimatedBuilder(
      animation: _press,
      builder: (context, child) {
        final double t = Curves.easeOut.transform(_press.value);
        return _LiquidGlassRender(
          controller: controller,
          style: widget.style,
          press: t,
          child: child,
        );
      },
      child: widget.child == null
          ? null
          : Padding(
              // Keep foreground content off the heavily-refracted rim.
              padding: const EdgeInsets.all(2),
              child: widget.child,
            ),
    );

    if (widget.width != null || widget.height != null) {
      lens = SizedBox(width: widget.width, height: widget.height, child: lens);
    }

    if (widget.onTap != null) {
      lens = GestureDetector(
        onTap: widget.onTap,
        onTapDown: _down,
        onTapUp: _up,
        onTapCancel: () => _press.reverse(),
        behavior: HitTestBehavior.opaque,
        child: lens,
      );
    }

    return lens;
  }
}

class _LiquidGlassRender extends SingleChildRenderObjectWidget {
  const _LiquidGlassRender({
    required this.controller,
    required this.style,
    required this.press,
    super.child,
  });

  final _GlassController? controller;
  final LiquidGlassStyle style;
  final double press;

  @override
  _RenderLiquidGlass createRenderObject(BuildContext context) {
    return _RenderLiquidGlass(
      controller: controller,
      style: style,
      press: press,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderLiquidGlass renderObject) {
    renderObject
      ..controller = controller
      ..style = style
      ..press = press;
  }
}

class _RenderLiquidGlass extends RenderProxyBox {
  _RenderLiquidGlass({
    required _GlassController? controller,
    required LiquidGlassStyle style,
    required double press,
  })  : _controller = controller,
        _style = style,
        _press = press;

  ui.FragmentShader? _shader;

  _GlassController? _controller;
  _GlassController? get controller => _controller;
  set controller(_GlassController? value) {
    if (_controller == value) return;
    if (attached) _controller?.removeListener(markNeedsPaint);
    _controller = value;
    if (attached) _controller?.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  LiquidGlassStyle _style;
  LiquidGlassStyle get style => _style;
  set style(LiquidGlassStyle value) {
    if (_style == value) return;
    _style = value;
    markNeedsPaint();
  }

  double _press;
  double get press => _press;
  set press(double value) {
    if (_press == value) return;
    _press = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _controller?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _controller?.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  double get _radius =>
      _style.borderRadius.clamp(0, size.shortestSide / 2).toDouble();

  RRect _rrect(Offset offset) =>
      RRect.fromRectAndRadius(offset & size, Radius.circular(_radius));

  @override
  void paint(PaintingContext context, Offset offset) {
    _paintGlass(context, offset);
    if (child != null) {
      context.pushClipRRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        _rrect(offset),
        (PaintingContext ctx, Offset off) => ctx.paintChild(child!, off),
        clipBehavior: Clip.antiAlias,
      );
    }
  }

  void _paintGlass(PaintingContext context, Offset offset) {
    final _GlassController? c = _controller;
    final ui.FragmentProgram? program = c?.program;
    final ui.Image? image = c?.image;
    final RenderObject? viewBox = c?.contentKey.currentContext?.findRenderObject();

    if (program == null || image == null || viewBox is! RenderBox || !viewBox.attached) {
      _paintFallback(context, offset);
      return;
    }

    // Lens position within the captured backdrop (logical pixels).
    final Offset lensOffset =
        localToGlobal(Offset.zero) - viewBox.localToGlobal(Offset.zero);

    final ui.FragmentShader shader = _shader ??= program.fragmentShader();
    final Color tint = _style.tint;
    shader
      ..setFloat(0, offset.dx)
      ..setFloat(1, offset.dy)
      ..setFloat(2, size.width)
      ..setFloat(3, size.height)
      ..setFloat(4, _radius)
      ..setFloat(5, image.width.toDouble())
      ..setFloat(6, image.height.toDouble())
      ..setFloat(7, lensOffset.dx)
      ..setFloat(8, lensOffset.dy)
      ..setFloat(9, c!.dpr)
      ..setFloat(10, _style.refraction)
      ..setFloat(11, _style.chromaticAberration)
      ..setFloat(12, tint.r)
      ..setFloat(13, tint.g)
      ..setFloat(14, tint.b)
      ..setFloat(15, _style.tintOpacity)
      ..setFloat(16, _style.highlight)
      ..setFloat(17, _press)
      ..setImageSampler(0, image);

    context.canvas.drawRect(offset & size, Paint()..shader = shader);
  }

  void _paintFallback(PaintingContext context, Offset offset) {
    final RRect rrect = _rrect(offset);
    final Paint fill = Paint()
      ..color = _style.tint.withValues(alpha: 0.18 + _style.tintOpacity);
    context.canvas
      ..save()
      ..clipRRect(rrect)
      ..drawRRect(rrect, fill)
      ..drawRRect(
        rrect.deflate(0.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: 0.35),
      )
      ..restore();
  }
}
