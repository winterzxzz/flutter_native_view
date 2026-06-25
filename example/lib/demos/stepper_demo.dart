import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

Widget buildStepperDemo() => const StepperDemo();

class StepperDemo extends StatefulWidget {
  const StepperDemo({super.key});
  @override
  State<StepperDemo> createState() => _StepperDemoState();
}

class _StepperDemoState extends State<StepperDemo> {
  int _guests = 2;
  int _rooms = 1;
  int _luggage = 0;

  @override
  Widget build(BuildContext context) {
    final int total = _guests * 150 + _rooms * 200 + _luggage * 30;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trip Extras',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add guests, rooms, and luggage to your booking.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          _StepperCard(
            icon: Icons.people,
            label: 'Guests',
            value: _guests,
            tint: const Color(0xFF0A84FF),
            subtitle: '\$150 / guest',
            min: 1,
            max: 10,
            onChanged: (v) => setState(() => _guests = v),
          ),
          const SizedBox(height: 16),

          _StepperCard(
            icon: Icons.bed,
            label: 'Rooms',
            value: _rooms,
            tint: const Color(0xFF30D158),
            subtitle: '\$200 / room',
            min: 1,
            max: 5,
            onChanged: (v) => setState(() => _rooms = v),
          ),
          const SizedBox(height: 16),

          _StepperCard(
            icon: Icons.luggage,
            label: 'Extra Luggage',
            value: _luggage,
            tint: const Color(0xFFFF9F0A),
            subtitle: '\$30 / piece',
            min: 0,
            max: 4,
            onChanged: (v) => setState(() => _luggage = v),
          ),
          const SizedBox(height: 16),

          // Total summary
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LiquidGlassContainer(
              tint: const Color(0xFFFF375F),
              borderRadius: 16,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$$total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color tint;
  final String subtitle;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _StepperCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
    required this.subtitle,
    required this.min,
    required this.max,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LiquidGlassStepper(
                value: value,
                onChanged: onChanged,
                min: min,
                max: max,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
