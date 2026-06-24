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
  final ScrollController _scroll = ScrollController();

  static const List<String> _labels = ['Today', 'News+', 'Sports', 'Audio'];

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Scrollable content — scroll down to minimize the bar, up to expand.
          ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
            itemCount: 40,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '${_labels[_index]}  ·  row $i'
                '${i == 0 ? '   (search tapped: $_searchTaps)' : ''}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ),
          // Native tab bar pinned to the bottom edge.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
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
              scrollController: _scroll,
            ),
          ),
        ],
      ),
    );
  }
}
