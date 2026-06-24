import 'package:flutter/material.dart';

/// A single action button inside a [LiquidGlassNavigationBar] or
/// [LiquidGlassToolbar].
class BarAction {
  const BarAction({
    required this.id,
    required this.sfSymbol,
    this.onPressed,
  });

  final String id;
  final String sfSymbol;
  final VoidCallback? onPressed;
}
