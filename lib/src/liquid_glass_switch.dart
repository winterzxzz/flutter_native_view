import 'package:flutter/widgets.dart';

import 'glass_box.dart';
import 'glass_style.dart';

/// A Liquid Glass toggle switch, rendered entirely in Flutter.
class LiquidGlassSwitch extends StatelessWidget {
  const LiquidGlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.tint,
    this.width = 56,
    this.height = 32,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  /// Glass tint while the switch is on. Defaults to a system-green.
  final Color? tint;

  final double width;
  final double height;

  static const Color _onColor = Color(0xFF34C759);

  @override
  Widget build(BuildContext context) {
    final double thumb = height - 6;
    final GlassStyle style = GlassStyle(
      cornerRadius: height / 2,
      blurSigma: 10,
      tint: value ? (tint ?? _onColor) : null,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: SizedBox(
        width: width,
        height: height,
        child: GlassBox(
          style: style,
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                width: thumb,
                height: thumb,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFFFFF),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: const Color(0xFF000000).withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
