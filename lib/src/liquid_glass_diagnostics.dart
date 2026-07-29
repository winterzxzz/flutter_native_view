import 'package:flutter/foundation.dart';

/// A metadata-only bridge event emitted by [LiquidGlassDiagnostics].
@immutable
final class LiquidGlassDiagnosticEvent {
  const LiquidGlassDiagnosticEvent({
    required this.viewType,
    required this.kind,
  });

  /// Native platform-view registration identifier.
  final String viewType;

  /// The lifecycle or traffic operation that occurred.
  final LiquidGlassDiagnosticEventKind kind;
}

/// Operations counted by deterministic Liquid Glass instrumentation.
enum LiquidGlassDiagnosticEventKind {
  viewCreated,
  configUpdate,
  nativeEvent,
  intrinsicMeasurement,
}

/// Immutable snapshot of bridge traffic counters.
@immutable
final class LiquidGlassDiagnosticsSnapshot {
  const LiquidGlassDiagnosticsSnapshot({
    required this.viewsCreated,
    required this.configUpdates,
    required this.nativeEvents,
    required this.intrinsicMeasurements,
  });

  final int viewsCreated;
  final int configUpdates;
  final int nativeEvents;
  final int intrinsicMeasurements;

  /// Total observed method-channel operations, excluding creation parameters.
  int get channelOperations =>
      configUpdates + nativeEvents + intrinsicMeasurements;
}

/// Deterministic, payload-free instrumentation for platform-view traffic.
///
/// Pass an instance to [LiquidGlassTheme]. Counters never retain label text,
/// input values, colors, or channel arguments, so diagnostics are safe to keep
/// enabled in development and performance tests.
final class LiquidGlassDiagnostics {
  LiquidGlassDiagnostics({this.onEvent});

  /// Optional live callback for each metadata-only event.
  final ValueChanged<LiquidGlassDiagnosticEvent>? onEvent;

  int _viewsCreated = 0;
  int _configUpdates = 0;
  int _nativeEvents = 0;
  int _intrinsicMeasurements = 0;

  /// Current immutable counters.
  LiquidGlassDiagnosticsSnapshot get snapshot => LiquidGlassDiagnosticsSnapshot(
    viewsCreated: _viewsCreated,
    configUpdates: _configUpdates,
    nativeEvents: _nativeEvents,
    intrinsicMeasurements: _intrinsicMeasurements,
  );

  /// Clears all counters without changing the callback.
  void reset() {
    _viewsCreated = 0;
    _configUpdates = 0;
    _nativeEvents = 0;
    _intrinsicMeasurements = 0;
  }

  @internal
  void record(String viewType, LiquidGlassDiagnosticEventKind kind) {
    switch (kind) {
      case LiquidGlassDiagnosticEventKind.viewCreated:
        _viewsCreated++;
      case LiquidGlassDiagnosticEventKind.configUpdate:
        _configUpdates++;
      case LiquidGlassDiagnosticEventKind.nativeEvent:
        _nativeEvents++;
      case LiquidGlassDiagnosticEventKind.intrinsicMeasurement:
        _intrinsicMeasurements++;
    }
    onEvent?.call(LiquidGlassDiagnosticEvent(viewType: viewType, kind: kind));
  }
}
