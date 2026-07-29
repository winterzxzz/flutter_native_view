import 'package:flutter/foundation.dart';

/// Tracks the last native snapshot using structural, not identity, equality.
///
/// Kept separate from the widget lifecycle so channel-deduplication and native
/// echo suppression can be proven with deterministic unit tests.
final class GlassConfigTracker {
  Map<String, Object?>? _last;

  @visibleForTesting
  Map<String, Object?>? get last => _last;

  void initialize(Map<String, Object?> snapshot) {
    _last = _freezeMap(snapshot);
  }

  /// Returns true exactly when [snapshot] differs from the last native state.
  bool shouldSend(Map<String, Object?> snapshot) {
    if (_deepEquals(snapshot, _last)) return false;
    _last = _freezeMap(snapshot);
    return true;
  }

  /// Applies state reported by native before a controlled Dart rebuild.
  void acceptNativeState(Map<String, Object?> patch) {
    final Map<String, Object?> current = <String, Object?>{...?_last};
    current.addAll(patch);
    _last = _freezeMap(current);
  }
}

/// Allows at most one scheduled configuration flush at a time.
///
/// The scheduler is injected so frame coalescing remains deterministic in
/// tests and independent of the Flutter engine clock.
final class GlassFrameSyncCoordinator {
  bool _scheduled = false;

  bool schedule({
    required void Function(VoidCallback callback) enqueue,
    required VoidCallback flush,
  }) {
    if (_scheduled) return false;
    _scheduled = true;
    enqueue(() {
      _scheduled = false;
      flush();
    });
    return true;
  }
}

bool _deepEquals(Object? left, Object? right) {
  if (identical(left, right)) return true;
  if (left is Map && right is Map) {
    if (left.length != right.length) return false;
    for (final Object? key in left.keys) {
      if (!right.containsKey(key) || !_deepEquals(left[key], right[key])) {
        return false;
      }
    }
    return true;
  }
  if (left is List && right is List) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (!_deepEquals(left[index], right[index])) return false;
    }
    return true;
  }
  return left == right;
}

Map<String, Object?> _freezeMap(Map<String, Object?> source) =>
    Map<String, Object?>.unmodifiable(
      source.map(
        (String key, Object? value) =>
            MapEntry<String, Object?>(key, _freeze(value)),
      ),
    );

Object? _freeze(Object? value) {
  if (value is Map<String, Object?>) return _freezeMap(value);
  if (value is Map) {
    return Map<Object?, Object?>.unmodifiable(
      value.map((Object? key, Object? item) => MapEntry(key, _freeze(item))),
    );
  }
  if (value is List) {
    return List<Object?>.unmodifiable(value.map<Object?>(_freeze));
  }
  return value;
}
