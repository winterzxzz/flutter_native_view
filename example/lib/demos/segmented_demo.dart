import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

class SegmentedDemo extends StatefulWidget {
  const SegmentedDemo({super.key});
  @override
  State<SegmentedDemo> createState() => _SegmentedDemoState();
}

class _SegmentedDemoState extends State<SegmentedDemo> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Selected: ${['Daily', 'Weekly', 'Monthly'][_index]}'),
          const SizedBox(height: 12),
          LiquidGlassSegmentedControl(
            segments: const ['Daily', 'Weekly', 'Monthly'],
            selectedIndex: _index,
            onChanged: (int i) => setState(() => _index = i),
            tint: Colors.blue,
          ),
        ],
      ),
    );
  }
}
