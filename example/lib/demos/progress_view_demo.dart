import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

Widget buildProgressViewDemo() {
  return const SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Monitor usage with native progress bars.',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        SizedBox(height: 20),

        _ProgressCard(
          label: 'Used Space',
          value: 0.65,
          detail: '65 GB of 100 GB',
          tint: Color(0xFFFF9F0A),
        ),
        SizedBox(height: 12),

        _ProgressCard(
          label: 'Free Space',
          value: 0.35,
          detail: '35 GB available',
          tint: Color(0xFF30D158),
        ),
        SizedBox(height: 12),

        _ProgressCard(
          label: 'System Cache',
          value: 0.12,
          detail: '12 GB cached',
          tint: Color(0xFF0A84FF),
        ),
        SizedBox(height: 12),

        _IndeterminateCard(),
      ],
    ),
  );
}

class _ProgressCard extends StatelessWidget {
  final String label;
  final double value;
  final String detail;
  final Color tint;

  const _ProgressCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final int pct = (value * 100).round();
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
                    '$pct%',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LiquidGlassProgressView(
                  value: value,
                  tint: tint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndeterminateCard extends StatelessWidget {
  const _IndeterminateCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: LiquidGlassContainer(
        tint: Color(0xFFFF375F),
        borderRadius: 16,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Loading',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Indeterminate progress for ongoing operations.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LiquidGlassProgressView(
                  tint: Color(0xFFFF375F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
