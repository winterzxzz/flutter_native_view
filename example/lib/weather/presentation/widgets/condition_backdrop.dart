import 'package:flutter/material.dart';

class ConditionBackdrop extends StatelessWidget {
  const ConditionBackdrop({super.key, required this.gradient});

  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final duration = disableAnimations ? Duration.zero : const Duration(milliseconds: 300);

    return Positioned.fill(
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeOut,
        child: Container(
          key: ObjectKey(gradient),
          decoration: BoxDecoration(gradient: gradient),
        ),
      ),
    );
  }
}
