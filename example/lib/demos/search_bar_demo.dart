import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

class SearchBarDemo extends StatefulWidget {
  const SearchBarDemo({super.key});
  @override
  State<SearchBarDemo> createState() => _SearchBarDemoState();
}

class _SearchBarDemoState extends State<SearchBarDemo> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  String _submitted = '';

  static const List<Map<String, String>> _allItems = [
    {'title': 'Profile Settings', 'symbol': 'person.circle'},
    {'title': 'Notifications', 'symbol': 'bell'},
    {'title': 'Privacy & Security', 'symbol': 'lock.shield'},
    {'title': 'Appearance', 'symbol': 'paintbrush'},
    {'title': 'Language & Region', 'symbol': 'globe'},
    {'title': 'Storage', 'symbol': 'externaldrive'},
    {'title': 'About', 'symbol': 'info.circle'},
    {'title': 'Help & Support', 'symbol': 'questionmark.circle'},
  ];

  List<Map<String, String>> get _results {
    if (_query.isEmpty) return _allItems;
    return _allItems
        .where((e) =>
            e['title']!.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings Search',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Type to search through settings.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LiquidGlassContainer(
              tint: const Color(0xFF6C63FF),
              borderRadius: 16,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LiquidGlassSearchBar(
                      text: _query,
                      onChanged: (String v) => setState(() => _query = v),
                      onSubmitted: (String v) =>
                          setState(() => _submitted = v),
                      placeholder: 'Search settings…',
                    ),
                    const SizedBox(height: 16),
                    if (_submitted.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Jumped to: $_submitted',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ..._results.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.white38,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              item['title']!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_results.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'No results found.',
                          style: TextStyle(color: Colors.white38, fontSize: 13),
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
