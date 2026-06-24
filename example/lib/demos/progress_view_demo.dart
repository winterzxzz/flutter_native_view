import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

const String progressViewDemoTitle = 'Liquid Glass Progress View';

Widget buildProgressViewDemo() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Progress View', style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 12),
        const LiquidGlassProgressView(value: 0.3, tint: Color(0xFF6C63FF)),
        const SizedBox(height: 16),
        const LiquidGlassProgressView(value: 0.7, tint: Color(0xFF00C853)),
        const SizedBox(height: 16),
        const LiquidGlassProgressView(tint: Color(0xFFFF6E7F)),
      ],
    ),
  );
}
