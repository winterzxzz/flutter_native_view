import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

const String tabBarDemoTitle = 'Liquid Glass Tab Bar';

Widget buildTabBarDemo() => const TabBarDemo();

class TabBarDemo extends StatefulWidget {
  const TabBarDemo({super.key});
  @override
  State<TabBarDemo> createState() => _TabBarDemoState();
}

class _TabBarDemoState extends State<TabBarDemo> {
  int _index = 0;

  static const List<String> _labels = ['Home', 'Search', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tab Bar', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 12),
          Text('Selected: ${_labels[_index]}',
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          LiquidGlassTabBar(
            items: const [
              TabItem(label: 'Home', sfSymbol: 'house'),
              TabItem(label: 'Search', sfSymbol: 'magnifyingglass'),
              TabItem(label: 'Profile', sfSymbol: 'person'),
            ],
            currentIndex: _index,
            onTap: (int index) => setState(() => _index = index),
          ),
        ],
      ),
    );
  }
}
