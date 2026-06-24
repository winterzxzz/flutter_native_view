import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

class SearchBarDemo extends StatefulWidget {
  const SearchBarDemo({super.key});
  @override
  State<SearchBarDemo> createState() => _SearchBarDemoState();
}

class _SearchBarDemoState extends State<SearchBarDemo> {
  String _text = '';
  String _submitted = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Native Search Bar', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          LiquidGlassSearchBar(
            text: _text,
            onChanged: (String v) => setState(() => _text = v),
            onSubmitted: (String v) => setState(() => _submitted = v),
            placeholder: 'Search...',
          ),
          const SizedBox(height: 12),
          Text('Text: "$_text"'),
          if (_submitted.isNotEmpty) Text('Submitted: "$_submitted"'),
        ],
      ),
    );
  }
}
