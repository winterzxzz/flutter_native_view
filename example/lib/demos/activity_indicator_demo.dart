import 'package:flutter/material.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

Widget buildActivityIndicatorDemo() {
  return const SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DemoCard(
          title: 'Loading',
          subtitle: 'Standard size indicator for content loads.',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LiquidGlassActivityIndicator(size: 24),
              SizedBox(width: 32),
              LiquidGlassActivityIndicator(size: 36, tint: Color(0xFF6C63FF)),
              SizedBox(width: 32),
              LiquidGlassActivityIndicator(size: 48, tint: Color(0xFF00C853)),
            ],
          ),
        ),
        SizedBox(height: 16),
        _DemoCard(
          title: 'Overlay',
          subtitle: 'Full-screen loading overlay for async operations.',
          child: SizedBox(
            height: 120,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LiquidGlassActivityIndicator(size: 32, tint: Color(0xFFFFFFFF)),
                      SizedBox(height: 12),
                      Text(
                        'Uploading…',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        _DemoCard(
          title: 'Pull to Refresh',
          subtitle: 'Refresh indicator style, tinted to match brand.',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LiquidGlassActivityIndicator(size: 28, tint: Color(0xFFFF9F0A)),
              SizedBox(width: 16),
              Text(
                'Refreshing…',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: LiquidGlassContainer(
        tint: const Color(0xFF6C63FF),
        borderRadius: 16,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
