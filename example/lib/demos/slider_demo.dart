import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

const String sliderDemoTitle = 'Liquid Glass Slider';

Widget buildSliderDemo() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Slider', style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 12),
        LiquidGlassSlider(
          value: 0.5,
          onChanged: (double v) {},
          min: 0,
          max: 1,
          tint: const Color(0xFF6C63FF),
        ),
        const SizedBox(height: 16),
        LiquidGlassSlider(
          value: 30,
          onChanged: (double v) {},
          min: 0,
          max: 100,
          tint: const Color(0xFF00C853),
        ),
      ],
    ),
  );
}
