import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

class ButtonDemo extends StatefulWidget {
  const ButtonDemo({super.key});
  @override
  State<ButtonDemo> createState() => _ButtonDemoState();
}

class _ButtonDemoState extends State<ButtonDemo> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LiquidGlassButton(
          label: 'Tapped $_count times',
          onPressed: () => setState(() => _count++),
        ),
        const SizedBox(height: 12),
        LiquidGlassButton.heading(
          label: 'Heading style',
          onPressed: () {},
          tint: Colors.orange,
        ),
      ],
    );
  }
}
