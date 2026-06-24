import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

class MenuDemo extends StatefulWidget {
  const MenuDemo({super.key});
  @override
  State<MenuDemo> createState() => _MenuDemoState();
}

class _MenuDemoState extends State<MenuDemo> {
  String _selected = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Tap to open menu'),
          const SizedBox(height: 12),
          LiquidGlassMenu(
            label: 'Options',
            sfSymbol: 'gearshape',
            items: const [
              MenuItem(id: 'edit', title: 'Edit', sfSymbol: 'pencil'),
              MenuItem(id: 'share', title: 'Share', sfSymbol: 'square.and.arrow.up'),
              MenuItem(id: 'delete', title: 'Delete', sfSymbol: 'trash'),
            ],
            onSelected: (String id) => setState(() => _selected = id),
          ),
          if (_selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('Selected: $_selected'),
            ),
        ],
      ),
    );
  }
}
