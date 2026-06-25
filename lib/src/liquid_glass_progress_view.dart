import 'package:flutter/material.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_theme.dart';

const String _kProgressViewType = 'flutter_native_view/glass_progress';

/// A native SwiftUI linear progress bar with Liquid Glass styling on iOS 26+.
///
/// On non-iOS platforms it falls back to a Material [LinearProgressIndicator].
class LiquidGlassProgressView extends StatefulWidget {
  const LiquidGlassProgressView({
    super.key,
    this.value = 0.0,
    this.tint,
    this.height = 8,
  });

  /// The current progress, from 0.0 to 1.0. Defaults to 0.0 (indeterminate).
  final double value;

  /// Optional tint color. Falls back to the [LiquidGlassTheme] tint.
  final Color? tint;

  /// Bar height. Defaults to 8. Width always fills the parent.
  final double height;

  @override
  State<LiquidGlassProgressView> createState() =>
      _LiquidGlassProgressViewState();
}

class _LiquidGlassProgressViewState extends State<LiquidGlassProgressView>
    with GlassPlatformViewMixin<LiquidGlassProgressView> {
  @override
  String get glassViewType => _kProgressViewType;

  @override
  Map<String, dynamic> buildParams() {
    final LiquidGlassThemeData t = LiquidGlassTheme.of(context);
    return <String, dynamic>{
      'value': widget.value,
      'tint': (widget.tint ?? t.tint)?.toARGB32(),
      'respectAccessibility': t.respectAccessibility,
    };
  }

  @override
  void didUpdateWidget(LiquidGlassProgressView oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncConfig();
  }

  @override
  Widget build(BuildContext context) {
    if (!isGlassPlatform) {
      return LinearProgressIndicator(
        value: widget.value > 0 ? widget.value : null,
        color: widget.tint,
      );
    }
    return glassView(
      width: double.infinity,
      height: widget.height,
      gesture: GlassGesture.none,
    );
  }
}
