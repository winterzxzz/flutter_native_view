import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

const String colorPickerDemoTitle = 'Liquid Glass Color Picker';

Widget buildColorPickerDemo() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color Picker', style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 12),
        LiquidGlassColorPicker(
          value: Colors.blue,
          onChanged: (Color v) {},
        ),
      ],
    ),
  );
}
