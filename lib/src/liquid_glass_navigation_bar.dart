import 'package:flutter/material.dart';

import 'bar_action.dart';
import 'liquid_glass_icon_button.dart';

/// A top navigation bar composed of Liquid Glass icon buttons.
///
/// This is pure Flutter layout — there is no dedicated native view. Each
/// [BarAction] in [leading]/[trailing] renders as a [LiquidGlassIconButton]
/// (authentic Apple glass on iOS 26+), and [title] is a Flutter [Text] centered
/// across the bar. The title is centered relative to the whole bar regardless of
/// how wide the leading/trailing buttons are, matching the system nav bar.
class LiquidGlassNavigationBar extends StatelessWidget {
  const LiquidGlassNavigationBar({
    super.key,
    this.title,
    this.leading = const [],
    this.trailing = const [],
    this.tint,
    this.iconColor = Colors.white,
    this.borderRadius,
  });

  final String? title;
  final List<BarAction> leading;
  final List<BarAction> trailing;

  /// Optional glass tint for the action buttons. When `null` (the default) the
  /// buttons render as clear, untinted glass — they do not inherit the
  /// [LiquidGlassTheme] tint. Pass a color to tint the glass.
  final Color? tint;

  /// Icon (SF Symbol) color for the action buttons. Defaults to white.
  final Color? iconColor;

  /// Corner radius for the action buttons. When `null` (the default) the buttons
  /// are circles. Pass a value for rounded-rectangle buttons.
  final double? borderRadius;

  Widget _button(BarAction a) => LiquidGlassIconButton(
        sfSymbol: a.sfSymbol,
        onPressed: a.onPressed,
        // Transparent (not null) so the button shows clear glass instead of
        // inheriting the theme tint, which is what `null` would do.
        tint: a.tint ?? tint ?? Colors.transparent,
        iconColor: a.iconColor ?? iconColor,
        borderRadius: borderRadius,
      );

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(top: topPadding, left: 12, right: 12),
      child: SizedBox(
        height: 56,
        // Stack so the title stays centered on the bar even when the leading and
        // trailing button groups have different widths. Buttons sit on top.
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (title != null)
              Center(
                child: Text(
                  title!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Row(
              children: [
                for (final BarAction a in leading) ...[
                  _button(a),
                  const SizedBox(width: 8),
                ],
                const Spacer(),
                for (final BarAction a in trailing) ...[
                  const SizedBox(width: 8),
                  _button(a),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
