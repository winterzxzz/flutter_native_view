import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

const String buttonGroupDemoTitle = 'Liquid Glass Button Group';

Widget buildButtonGroupDemo() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Button Group', style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 12),
        LiquidGlassButtonGroup(
          buttons: [
            GroupButton(id: 'heart', sfSymbol: 'heart', onPressed: () {}),
            GroupButton(id: 'star', sfSymbol: 'star', onPressed: () {}),
            GroupButton(id: 'bell', sfSymbol: 'bell', onPressed: () {}),
          ],
        ),
      ],
    ),
  );
}
