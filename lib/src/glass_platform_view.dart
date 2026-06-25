import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// How the embedded [UiKitView] should claim touches.
enum GlassGesture {
  /// No gesture recognizers — the view is purely decorative (e.g. a spinner).
  none,

  /// Claim the tap sequence only. Use for buttons that fire on release while
  /// letting scroll/drag pass through to Flutter.
  tap,

  /// Claim every touch eagerly. Use for views that handle their own drag/typing
  /// (sliders, switches, text fields, tab bars).
  eager,
}

/// Shared lifecycle for every glass widget that embeds a native iOS
/// [UiKitView] over a per-view [MethodChannel].
///
/// Mixing this in gives a widget, for free and in one place:
///
/// * a [channel] created with the standard `"<viewType>/<id>"` name,
/// * **handler cleanup on [dispose]** (prevents `setState`-after-unmount and
///   retained-closure leaks),
/// * optional intrinsic-size measurement with a fade-in that hides the
///   placeholder→measured size correction,
/// * [syncConfig], a params-diffing `updateConfig` call that replaces hand
///   written per-field `didUpdateWidget` checks (so a newly added parameter
///   can never be silently dropped from the native update).
///
/// A widget supplies [glassViewType] and [buildParams]; everything else has a
/// sensible default. Override [handleCall] to receive native→Dart callbacks,
/// and set [measuresSize] when the native view reports its own size.
mixin GlassPlatformViewMixin<T extends StatefulWidget> on State<T> {
  MethodChannel? _channel;
  Size? _size;
  Map<String, dynamic>? _lastParams;

  /// The live channel to the native view, or `null` before creation / after
  /// dispose. Use it for lightweight one-shot calls such as `setValue`.
  @protected
  MethodChannel? get channel => _channel;

  /// The last size reported by the native view, or `null` until it reports one.
  @protected
  Size? get measuredSize => _size;

  /// The platform-view registration id, e.g.
  /// `'flutter_native_view/glass_button'`. The per-instance channel name is
  /// derived from this as `'<glassViewType>/<id>'`.
  @protected
  String get glassViewType;

  /// The full parameter map sent to the native view on creation and, when it
  /// changes, via `updateConfig`. Read theme values here.
  @protected
  Map<String, dynamic> buildParams();

  /// Handles native→Dart method calls (events such as `onPressed`,
  /// `onChanged`). Defaults to ignoring everything.
  @protected
  Future<dynamic> handleCall(MethodCall call) async => null;

  /// Whether the native view reports its own intrinsic size. When `true`,
  /// [glassView] sizes itself to the measurement and fades in once it arrives.
  @protected
  bool get measuresSize => false;

  /// Wire up [onPlatformViewCreated]. Creates the channel, installs
  /// [handleCall], and — when [measuresSize] — fetches the intrinsic size.
  @protected
  Future<void> onGlassViewCreated(int id) async {
    final MethodChannel ch = MethodChannel('$glassViewType/$id');
    ch.setMethodCallHandler(handleCall);
    _channel = ch;
    _lastParams = buildParams();
    if (measuresSize) {
      await _applySize(ch.invokeMapMethod<String, dynamic>('getIntrinsicSize'));
    }
  }

  /// Push current [buildParams] to the native view when they differ from the
  /// last sent set. Call this from `didUpdateWidget`. Diffing the whole map
  /// means no parameter can be forgotten in a hand-maintained field list.
  @protected
  void syncConfig() {
    final Map<String, dynamic> next = buildParams();
    if (mapEquals(next, _lastParams)) return;
    _lastParams = next;
    final Future<Map<String, dynamic>?>? res =
        _channel?.invokeMapMethod<String, dynamic>('updateConfig', next);
    if (measuresSize && res != null) _applySize(res);
  }

  Future<void> _applySize(Future<Map<String, dynamic>?> call) async {
    final Map<String, dynamic>? res = await call;
    if (res == null || !mounted) return;
    final Size next = Size(
      (res['width'] as num).toDouble(),
      (res['height'] as num).toDouble(),
    );
    // Skip the rebuild when the measured size is unchanged — e.g. a counter
    // label "Tapped 0" → "Tapped 1" keeps the same width, so re-running
    // setState would needlessly repaint the platform view (visible flash).
    if (_size == next) return;
    setState(() => _size = next);
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    super.dispose();
  }

  /// Builds the iOS [UiKitView] wrapped in a [SizedBox].
  ///
  /// Sizing precedence: an explicit [width]/[height], else the native
  /// [measuredSize], else [estimatedSize]. When [measuresSize] is on, the view
  /// stays invisible at the estimated size and fades in once the real size
  /// arrives, hiding the placeholder→measured correction.
  ///
  /// Off iOS this is never called — return your [fallback] in `build` first.
  @protected
  Widget glassView({
    double? width,
    double? height,
    Size estimatedSize = const Size(120, 44),
    GlassGesture gesture = GlassGesture.tap,
  }) {
    final Size size = Size(
      width ?? _size?.width ?? estimatedSize.width,
      height ?? _size?.height ?? estimatedSize.height,
    );

    final Widget view = SizedBox(
      width: size.width,
      height: size.height,
      child: UiKitView(
        viewType: glassViewType,
        creationParams: buildParams(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onGlassViewCreated,
        gestureRecognizers: _recognizers(gesture),
      ),
    );

    // Fade in only for measured views, where the estimate may be wrong. Fixed
    // and fill-width views already know their size, so show them immediately.
    if (!measuresSize) return view;
    return AnimatedOpacity(
      opacity: _size == null ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: view,
    );
  }

  Set<Factory<OneSequenceGestureRecognizer>> _recognizers(GlassGesture g) {
    switch (g) {
      case GlassGesture.none:
        return const <Factory<OneSequenceGestureRecognizer>>{};
      case GlassGesture.tap:
        return <Factory<OneSequenceGestureRecognizer>>{
          Factory<TapGestureRecognizer>(TapGestureRecognizer.new),
        };
      case GlassGesture.eager:
        return <Factory<OneSequenceGestureRecognizer>>{
          Factory<EagerGestureRecognizer>(EagerGestureRecognizer.new),
        };
    }
  }
}

/// Convenience shorthand for the common iOS check used by every glass widget.
bool get isGlassPlatform => defaultTargetPlatform == TargetPlatform.iOS;
