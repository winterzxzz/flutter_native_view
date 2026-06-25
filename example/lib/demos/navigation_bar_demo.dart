import 'package:flutter/material.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

Widget buildNavigationBarDemo() {
  return const SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Navigation',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Native navigation bars for your app screens.',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        SizedBox(height: 20),

        _NavCard(
          title: 'Standard',
          description: 'Title with leading and trailing actions.',
          trailing: 'share, settings',
          child: LiquidGlassNavigationBar(
            title: 'My App',
            leading: [
              BarAction(id: 'back', sfSymbol: 'chevron.left', onPressed: null),
            ],
            trailing: [
              BarAction(id: 'share', sfSymbol: 'square.and.arrow.up', onPressed: null),
              BarAction(id: 'settings', sfSymbol: 'gear', onPressed: null),
            ],
          ),
        ),
        SizedBox(height: 16),

        _NavCard(
          title: 'Detail',
          description: 'Context-specific bar with edit action.',
          trailing: 'edit, more',
          child: LiquidGlassNavigationBar(
            title: 'Note',
            leading: [
              BarAction(id: 'back', sfSymbol: 'chevron.left', onPressed: null),
            ],
            trailing: [
              BarAction(id: 'edit', sfSymbol: 'pencil', onPressed: null),
              BarAction(id: 'more', sfSymbol: 'ellipsis', onPressed: null),
            ],
            tint: Color(0xFF0A84FF),
          ),
        ),
        SizedBox(height: 16),

        _NavCard(
          title: 'Media',
          description: 'Media player bar with playback actions.',
          trailing: 'play, forward',
          child: LiquidGlassNavigationBar(
            title: 'Now Playing',
            leading: [
              BarAction(id: 'down', sfSymbol: 'chevron.down', onPressed: null),
            ],
            trailing: [
              BarAction(id: 'play', sfSymbol: 'play.fill', onPressed: null),
              BarAction(id: 'forward', sfSymbol: 'forward.fill', onPressed: null),
            ],
            tint: Color(0xFFFF375F),
          ),
        ),
      ],
    ),
  );
}

class _NavCard extends StatelessWidget {
  final String title;
  final String description;
  final String trailing;
  final Widget child;

  const _NavCard({
    required this.title,
    required this.description,
    required this.trailing,
    required this.child,
  });

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
              Row(
                children: [
                  Expanded(
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
                        SizedBox(height: 2),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    trailing,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
