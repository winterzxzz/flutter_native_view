import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

class IconButtonDemo extends StatefulWidget {
  const IconButtonDemo({super.key});
  @override
  State<IconButtonDemo> createState() => _IconButtonDemoState();
}

class _IconButtonDemoState extends State<IconButtonDemo> {
  int _likes = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Likes: $_likes'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            LiquidGlassIconButton(
              sfSymbol: 'heart',
              onPressed: () => setState(() => _likes++),
            ),
            LiquidGlassIconButton(
              sfSymbol: 'star.fill',
              onPressed: () {},
              tint: Colors.amber,
            ),
            LiquidGlassIconButton(
              sfSymbol: 'trash',
              onPressed: () {},
              tint: Colors.red,
              size: 52,
              iconSize: 24,
            ),
          ],
        ),
      ],
    );
  }
}
