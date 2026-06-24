import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

const String colorPickerDemoTitle = 'Liquid Glass Color Picker';

Widget buildColorPickerDemo() => const ColorPickerDemo();

class ColorPickerDemo extends StatefulWidget {
  const ColorPickerDemo({super.key});
  @override
  State<ColorPickerDemo> createState() => _ColorPickerDemoState();
}

class _ColorPickerDemoState extends State<ColorPickerDemo> {
  Color _color = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Color Picker', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 12),
          LiquidGlassColorPicker(
            value: _color,
            onChanged: (Color v) => setState(() => _color = v),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(width: 32, height: 32, color: _color),
              const SizedBox(width: 12),
              Text(
                '#${_color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
