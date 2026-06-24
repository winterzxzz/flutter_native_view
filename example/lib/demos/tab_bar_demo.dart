import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

const String tabBarDemoTitle = 'Liquid Glass Tab Bar';

Widget buildTabBarDemo() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tab Bar', style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 12),
        LiquidGlassTabBar(
          items: [
            TabItem(label: 'Home', sfSymbol: 'house'),
            TabItem(label: 'Search', sfSymbol: 'magnifyingglass'),
            TabItem(label: 'Profile', sfSymbol: 'person'),
          ],
          currentIndex: 0,
          onTap: (int index) {},
        ),
      ],
    ),
  );
}
