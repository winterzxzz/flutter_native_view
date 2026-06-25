import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

Widget buildSliderDemo() => const SliderDemo();

class SliderDemo extends StatefulWidget {
  const SliderDemo({super.key});
  @override
  State<SliderDemo> createState() => _SliderDemoState();
}

class _SliderDemoState extends State<SliderDemo> {
  double _brightness = 0.7;
  double _volume = 0.4;
  double _fontSize = 0.6;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Display & Sound',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Adjust settings with native sliders.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Brightness
          _SliderCard(
            icon: Icons.sunny,
            label: 'Brightness',
            value: _brightness,
            tint: const Color(0xFFFF9F0A),
            display: '${(_brightness * 100).round()}%',
            onChanged: (v) => setState(() => _brightness = v),
          ),
          const SizedBox(height: 16),

          // Volume
          _SliderCard(
            icon: Icons.volume_up,
            label: 'Volume',
            value: _volume,
            tint: const Color(0xFF0A84FF),
            display: '${(_volume * 100).round()}%',
            onChanged: (v) => setState(() => _volume = v),
          ),
          const SizedBox(height: 16),

          // Font Size
          _SliderCard(
            icon: Icons.text_fields,
            label: 'Text Size',
            value: _fontSize,
            tint: const Color(0xFF30D158),
            display: '${(_fontSize * 100).round()}%',
            onChanged: (v) => setState(() => _fontSize = v),
          ),
        ],
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color tint;
  final String display;
  final ValueChanged<double> onChanged;

  const _SliderCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
    required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: LiquidGlassContainer(
        tint: tint,
        borderRadius: 16,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    display,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LiquidGlassSlider(
                value: value,
                onChanged: onChanged,
                min: 0,
                max: 1,
                tint: tint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
