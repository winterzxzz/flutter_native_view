import 'package:flutter/material.dart';

import 'liquid_glass_switch.dart';

/// A [LiquidGlassSwitch] paired with a leading text label in a single row.
///
/// A convenience over building the `Row(label + switch)` yourself, matching the
/// common "setting row" layout:
///
/// ```dart
/// LiquidGlassLabeledSwitch(
///   label: 'Wi-Fi',
///   value: wifiOn,
///   onChanged: (v) => setState(() => wifiOn = v),
/// )
/// ```
class LiquidGlassLabeledSwitch extends StatelessWidget {
  const LiquidGlassLabeledSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.tint,
    this.labelStyle,
  });

  /// Text shown before the switch.
  final String label;

  /// Current switch value.
  final bool value;

  /// Called when the switch is toggled.
  final ValueChanged<bool> onChanged;

  /// Optional tint for the switch's on state.
  final Color? tint;

  /// Optional text style for [label].
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(child: Text(label, style: labelStyle)),
        const SizedBox(width: 12),
        LiquidGlassSwitch(value: value, onChanged: onChanged, tint: tint),
      ],
    );
  }
}
