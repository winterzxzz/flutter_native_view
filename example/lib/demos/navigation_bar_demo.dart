import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

const String navigationBarDemoTitle = 'Liquid Glass Navigation Bar';

Widget buildNavigationBarDemo() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Navigation Bar', style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 12),
        LiquidGlassNavigationBar(
          title: 'My App',
          leading: [
            BarAction(id: 'back', sfSymbol: 'chevron.left', onPressed: () {}),
          ],
          trailing: [
            BarAction(id: 'share', sfSymbol: 'square.and.arrow.up', onPressed: () {}),
            BarAction(id: 'settings', sfSymbol: 'gear', onPressed: () {}),
          ],
        ),
      ],
    ),
  );
}
