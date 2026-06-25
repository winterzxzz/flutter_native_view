import 'package:flutter/material.dart';

/// A single action button inside a [LiquidGlassNavigationBar] or
/// [LiquidGlassToolbar].
class BarAction {
  const BarAction({
    required this.id,
    required this.sfSymbol,
    this.onPressed,
    this.tint,
    this.iconColor,
  });

  /// Stable identifier for this action, used to route taps back from native.
  final String id;

  /// SF Symbol name for the action's icon (e.g. `chevron.left`, `ellipsis`).
  final String sfSymbol;

  /// Called when the action is tapped. When `null`, the action is disabled.
  final VoidCallback? onPressed;

  /// Optional per-action glass tint color. Overrides any bar-level tint.
  final Color? tint;

  /// Optional per-action icon foreground color. Overrides any bar-level icon
  /// color.
  final Color? iconColor;
}
