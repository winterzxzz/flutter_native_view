
import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

Widget buildColorPickerDemo() => const ColorPickerDemo();

class ColorPickerDemo extends StatefulWidget {
  const ColorPickerDemo({super.key});
  @override
  State<ColorPickerDemo> createState() => _ColorPickerDemoState();
}

class _ColorPickerDemoState extends State<ColorPickerDemo> {
  Color _color = const Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    final String hex = '#${_color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme Color',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pick a brand color and preview it in context.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Color picker & preview row
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LiquidGlassContainer(
              tint: _color,
              borderRadius: 16,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Picker',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LiquidGlassColorPicker(
                      value: _color,
                      onChanged: (Color v) => setState(() => _color = v),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hex,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'monospace',
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preview cards using the selected color
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LiquidGlassContainer(
              tint: _color,
              borderRadius: 16,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tinted button & accent
                    Row(
                      children: [
                        LiquidGlassButton(
                          label: 'Primary Action',
                          onPressed: () {},
                          tint: _color,
                        ),
                        const SizedBox(width: 12),
                        LiquidGlassIconButton(
                          sfSymbol: 'heart.fill',
                          onPressed: () {},
                          tint: _color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 4,
                        width: double.infinity,
                        child: LiquidGlassProgressView(value: 0.65, tint: _color),
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
