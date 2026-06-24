import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

const String sliderDemoTitle = 'Liquid Glass Slider';

Widget buildSliderDemo() => const SliderDemo();

class SliderDemo extends StatefulWidget {
  const SliderDemo({super.key});
  @override
  State<SliderDemo> createState() => _SliderDemoState();
}

class _SliderDemoState extends State<SliderDemo> {
  double _a = 0.5;
  double _b = 30;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Slider', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 12),
          Text('Value: ${_a.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white70)),
          LiquidGlassSlider(
            value: _a,
            onChanged: (double v) => setState(() => _a = v),
            min: 0,
            max: 1,
            tint: const Color(0xFF6C63FF),
          ),
          const SizedBox(height: 16),
          Text('Value: ${_b.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white70)),
          LiquidGlassSlider(
            value: _b,
            onChanged: (double v) => setState(() => _b = v),
            min: 0,
            max: 100,
            tint: const Color(0xFF00C853),
          ),
        ],
      ),
    );
  }
}
