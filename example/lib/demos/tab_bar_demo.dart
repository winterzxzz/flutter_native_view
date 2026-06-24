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
  int _searchTaps = 0;

  static const List<String> _labels = ['Today', 'News+', 'Sports', 'Audio'];

  @override
  Widget build(BuildContext context) {
    // Fill the page so the bar can pin to the bottom like a real tab bar.
    return SizedBox.expand(
      child: Stack(
        children: [
          // Page content for the selected tab.
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _labels[_index],
                  style: const TextStyle(color: Colors.white, fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  'Search tapped: $_searchTaps',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
          // Floating glass tab bar pinned to the bottom.
          Positioned(
            left: 8,
            right: 8,
            bottom: 12,
            child: LiquidGlassTabBar(
              items: const [
                TabItem(label: 'Today', sfSymbol: 'newspaper'),
                TabItem(label: 'News+', sfSymbol: 'square.grid.2x2'),
                TabItem(label: 'Sports', sfSymbol: 'sportscourt'),
                TabItem(label: 'Audio', sfSymbol: 'headphones'),
              ],
              currentIndex: _index,
              onTap: (int index) => setState(() => _index = index),
              accessorySymbol: 'magnifyingglass',
              onAccessoryTap: () => setState(() => _searchTaps++),
              tint: const Color(0xFFFF375F),
            ),
          ),
        ],
      ),
    );
  }
}
