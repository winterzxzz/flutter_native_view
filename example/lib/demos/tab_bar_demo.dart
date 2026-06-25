import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

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
  static const List<IconData> _icons = [
    Icons.newspaper,
    Icons.grid_view,
    Icons.sports_soccer,
    Icons.headphones,
  ];

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
          ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
            itemCount: 40,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Card(
                color: Colors.white.withValues(alpha: 0.05),
                child: ListTile(
                  leading: Icon(
                    _icons[_index],
                    color: Colors.white54,
                    size: 24,
                  ),
                  title: Text(
                    '${_labels[_index]}  \u00b7  article $i',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    i == 0
                        ? 'Search tapped: $_searchTaps'
                        : 'Swipe down to explore',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ),
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
              onAccessoryTap: () {
                setState(() => _searchTaps++);
                // DIAGNOSTIC: proves the accessory tap reached Flutter.
                debugPrint('[search] accessory tapped #$_searchTaps');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Search tapped #$_searchTaps')),
                );
                LiquidGlassSheet.show(context: context, title: 'Search');
              },
              tint: Color(0xFFFF375F),
              scrollController: _scroll,
            ),
          ),
        ],
      ),
    );
  }
}
