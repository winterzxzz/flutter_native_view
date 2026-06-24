import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

const String toolbarDemoTitle = 'Liquid Glass Toolbar';

Widget buildToolbarDemo() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Toolbar', style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 12),
        LiquidGlassToolbar(
          actions: [
            BarAction(id: 'trash', sfSymbol: 'trash', onPressed: () {}),
            BarAction(id: 'folder', sfSymbol: 'folder', onPressed: () {}),
            BarAction(id: 'tag', sfSymbol: 'tag', onPressed: () {}),
          ],
        ),
      ],
    ),
  );
}
