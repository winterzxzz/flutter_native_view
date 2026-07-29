import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_config_tracker.dart';
import 'liquid_glass_diagnostics.dart';
import 'liquid_glass_style.dart';
import 'liquid_glass_theme.dart';

enum GlassGesture { tap, eager }

/// Shared platform-view lifecycle and synchronization for every native control.
mixin GlassPlatformViewMixin<T extends StatefulWidget> on State<T> {
  final GlassConfigTracker _tracker = GlassConfigTracker();
  final GlassFrameSyncCoordinator _syncCoordinator =
      GlassFrameSyncCoordinator();
  MethodChannel? _channel;
  Size? _size;
  int _configRevision = 0;
  LiquidGlassDiagnostics? _activeDiagnostics;

  @protected
  MethodChannel? get channel => _channel;

  @protected
  Size? get measuredSize => _size;

  @protected
  String get glassViewType;

  @protected
  Map<String, Object?> buildParams();

  @protected
  Future<Object?> handleCall(MethodCall call) async => null;

  @protected
  bool get measuresSize => false;

  Future<Object?> _receiveCall(MethodCall call) {
    _activeDiagnostics?.record(
      glassViewType,
      LiquidGlassDiagnosticEventKind.nativeEvent,
    );
    return handleCall(call);
  }

  @protected
  Future<void> onGlassViewCreated(
    int id,
    Map<String, Object?> creationSnapshot,
  ) async {
    if (!mounted) return;
    final MethodChannel next = MethodChannel('$glassViewType/$id');
    _channel?.setMethodCallHandler(null);
    next.setMethodCallHandler(_receiveCall);
    _channel = next;
    // The platform view owns the snapshot passed when it was constructed, not
    // necessarily the widget's current snapshot when asynchronous creation
    // completes. Start from that exact state, then immediately catch up.
    _tracker.initialize(creationSnapshot);
    _activeDiagnostics?.record(
      glassViewType,
      LiquidGlassDiagnosticEventKind.viewCreated,
    );
    _flushConfig();
    if (measuresSize) {
      _activeDiagnostics?.record(
        glassViewType,
        LiquidGlassDiagnosticEventKind.intrinsicMeasurement,
      );
      await _applySize(
        next.invokeMapMethod<String, Object?>('getIntrinsicSize'),
        revision: _configRevision,
      );
    }
  }

  /// Schedules at most one full-snapshot update after the current frame.
  @protected
  void syncConfig() {
    if (_channel == null) return;
    _syncCoordinator.schedule(
      enqueue: (VoidCallback callback) {
        final WidgetsBinding binding = WidgetsBinding.instance;
        binding.addPostFrameCallback((_) => callback());
        // Native events can require a controlled-value reconciliation even
        // when the callback deliberately does not rebuild the parent.
        binding.ensureVisualUpdate();
      },
      flush: () {
        if (mounted) _flushConfig();
      },
    );
  }

  void _flushConfig() {
    final MethodChannel? activeChannel = _channel;
    if (activeChannel == null) return;
    final Map<String, Object?> next = buildParams();
    if (!_tracker.shouldSend(next)) return;
    final int revision = ++_configRevision;
    _activeDiagnostics?.record(
      glassViewType,
      LiquidGlassDiagnosticEventKind.configUpdate,
    );
    final Future<Map<String, Object?>?> response = activeChannel
        .invokeMapMethod<String, Object?>('updateConfig', next);
    if (measuresSize) {
      _applySize(response, revision: revision);
    }
  }

  /// Dispatches an optimistic native value and reconciles it after the frame.
  ///
  /// [notify] runs after the tracker patch. Reconciliation is scheduled in a
  /// `finally` block so a callback exception cannot strand optimistic native
  /// state. If the callback accepts the value and rebuilds, the new widget
  /// snapshot matches native and no update is sent. If it rejects the value or
  /// does not rebuild, the authoritative widget snapshot is sent back.
  @protected
  void dispatchControlledNativeState(
    Map<String, Object?> patch,
    VoidCallback notify,
  ) {
    _tracker.acceptNativeState(patch);
    try {
      notify();
    } finally {
      syncConfig();
    }
  }

  Future<void> _applySize(
    Future<Map<String, Object?>?> call, {
    required int revision,
  }) async {
    final Map<String, Object?>? result = await call;
    if (result == null || !mounted || revision != _configRevision) return;
    final Object? rawWidth = result['width'];
    final Object? rawHeight = result['height'];
    if (rawWidth is! num || rawHeight is! num) return;
    final Size next = Size(rawWidth.toDouble(), rawHeight.toDouble());
    if (!next.width.isFinite ||
        !next.height.isFinite ||
        next.width <= 0 ||
        next.height <= 0 ||
        _size == next) {
      return;
    }
    setState(() => _size = next);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activeDiagnostics = LiquidGlassTheme.maybeOf(context)?.diagnostics;
    syncConfig();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncConfig();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    super.dispose();
  }

  @protected
  Widget glassView({
    double? width,
    double? height,
    Size estimatedSize = const Size(120, 44),
    GlassGesture gesture = GlassGesture.tap,
  }) {
    final Map<String, Object?> creationSnapshot = buildParams();
    final Size size = Size(
      width ?? _size?.width ?? estimatedSize.width,
      height ?? _size?.height ?? estimatedSize.height,
    );
    final Widget view = SizedBox(
      width: size.width,
      height: size.height,
      child: UiKitView(
        viewType: glassViewType,
        creationParams: creationSnapshot,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (int id) =>
            onGlassViewCreated(id, creationSnapshot),
        gestureRecognizers: _recognizers(gesture),
      ),
    );
    if (!measuresSize) return view;
    return AnimatedOpacity(
      opacity: _size == null ? 0 : 1,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: view,
    );
  }
}

Set<Factory<OneSequenceGestureRecognizer>> _recognizers(GlassGesture gesture) {
  return switch (gesture) {
    GlassGesture.tap => <Factory<OneSequenceGestureRecognizer>>{
      Factory<TapGestureRecognizer>(TapGestureRecognizer.new),
    },
    GlassGesture.eager => <Factory<OneSequenceGestureRecognizer>>{
      Factory<EagerGestureRecognizer>(EagerGestureRecognizer.new),
    },
  };
}

@visibleForTesting
bool isGlassPlatformFor({
  required TargetPlatform platform,
  required bool isWeb,
}) => !isWeb && platform == TargetPlatform.iOS;

bool get isGlassPlatform =>
    isGlassPlatformFor(platform: defaultTargetPlatform, isWeb: kIsWeb);

@protected
LiquidGlassStyle resolveGlassStyle(
  BuildContext context,
  LiquidGlassStyle? explicit,
) => explicit ?? LiquidGlassTheme.of(context).style;

@protected
LiquidGlassControlStyle resolveControlStyle(
  BuildContext context,
  LiquidGlassControlStyle? explicit,
) => explicit ?? LiquidGlassTheme.of(context).controlStyle;

@protected
Map<String, Object?> encodeStyles(
  LiquidGlassStyle style,
  LiquidGlassControlStyle controlStyle,
) {
  final LiquidGlassShape shape = style.shape;
  final Map<String, Object?> encodedShape = switch (shape) {
    LiquidGlassCapsuleShape() => const <String, Object?>{'kind': 'capsule'},
    LiquidGlassCircleShape() => const <String, Object?>{'kind': 'circle'},
    LiquidGlassRoundedRectangleShape(:final cornerRadius) => <String, Object?>{
      'kind': 'roundedRectangle',
      'cornerRadius': cornerRadius,
    },
  };
  return <String, Object?>{
    'style': <String, Object?>{
      'variant': style.variant.name,
      'tint': style.tint?.toARGB32(),
      'shape': encodedShape,
      'interactive': style.interactive,
    },
    ...encodeControlStyle(controlStyle),
  };
}

@protected
Map<String, Object?> encodeControlStyle(LiquidGlassControlStyle controlStyle) =>
    <String, Object?>{
      'controlStyle': <String, Object?>{
        'tintColor': controlStyle.tintColor?.toARGB32(),
        'foregroundColor': controlStyle.foregroundColor?.toARGB32(),
        'brightness': controlStyle.brightness?.name,
        'size': controlStyle.size.name,
        'disabledOpacity': controlStyle.disabledOpacity,
      },
    };

@protected
BorderRadius fallbackBorderRadius(LiquidGlassShape shape) => switch (shape) {
  LiquidGlassRoundedRectangleShape(:final cornerRadius) =>
    BorderRadius.circular(cornerRadius),
  LiquidGlassCapsuleShape() => BorderRadius.circular(999),
  LiquidGlassCircleShape() => BorderRadius.circular(999),
};

@protected
OutlinedBorder fallbackOutlinedBorder(LiquidGlassShape shape) =>
    switch (shape) {
      LiquidGlassRoundedRectangleShape(:final cornerRadius) =>
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
      LiquidGlassCapsuleShape() => const StadiumBorder(),
      LiquidGlassCircleShape() => const CircleBorder(),
    };

@protected
Widget applyFallbackControlStyle({
  required Widget child,
  required LiquidGlassControlStyle controlStyle,
  required bool enabled,
}) {
  Widget result = child;
  if (controlStyle.foregroundColor case final Color foreground) {
    result = DefaultTextStyle.merge(
      style: TextStyle(color: foreground),
      child: IconTheme.merge(
        data: IconThemeData(color: foreground),
        child: result,
      ),
    );
  }
  if (!enabled) {
    result = Opacity(opacity: controlStyle.disabledOpacity, child: result);
  }
  if (controlStyle.brightness case final Brightness brightness) {
    result = Theme(
      data: ThemeData(brightness: brightness),
      child: result,
    );
  }
  return result;
}
