import 'package:flutter/material.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

class SegmentedDemo extends StatefulWidget {
  const SegmentedDemo({super.key});
  @override
  State<SegmentedDemo> createState() => _SegmentedDemoState();
}

class _SegmentedDemoState extends State<SegmentedDemo> {
  int _period = 0;
  int _difficulty = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Switch between time periods and filters.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LiquidGlassContainer(
              tint: const Color(0xFF0A84FF),
              borderRadius: 16,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Time Range',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LiquidGlassSegmentedControl(
                      segments: const ['Daily', 'Weekly', 'Monthly'],
                      selectedIndex: _period,
                      onChanged: (int i) => setState(() => _period = i),
                      tint: const Color(0xFF0A84FF),
                    ),
                    const SizedBox(height: 16),
                    _dataRow(_period),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LiquidGlassContainer(
              tint: const Color(0xFF30D158),
              borderRadius: 16,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Difficulty',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LiquidGlassSegmentedControl(
                      segments: const ['Easy', 'Medium', 'Hard'],
                      selectedIndex: _difficulty,
                      onChanged: (int i) => setState(() => _difficulty = i),
                      tint: const Color(0xFF30D158),
                    ),
                    const SizedBox(height: 16),
                    _difficultyRow(_difficulty),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataRow(int index) {
    final data = [
      ['1,240', '8,420', '32.1k'],
      ['\$4.2k', '\$28.9k', '\$124.5k'],
      ['86%', '92%', '88%'],
    ];
    final labels = ['Visitors', 'Revenue', 'Conversion'];
    return Column(
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                labels[i],
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              Text(
                data[i][index],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _difficultyRow(int index) {
    final tips = [
      'Perfect for beginners. Covers all fundamentals.',
      'Moderate pace with some advanced topics.',
      'Expert-level content. Requires prior experience.',
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.white54, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tips[index],
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
