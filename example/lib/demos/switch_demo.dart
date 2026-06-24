import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

class SwitchDemo extends StatefulWidget {
  const SwitchDemo({super.key});
  @override
  State<SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<SwitchDemo> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassSwitch(
      value: _value,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}
