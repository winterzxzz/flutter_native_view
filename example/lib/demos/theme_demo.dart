import 'package:flutter/material.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

Widget buildThemeDemo() => const ThemeDemo();

class ThemeDemo extends StatefulWidget {
  const ThemeDemo({super.key});
  @override
  State<ThemeDemo> createState() => _ThemeDemoState();
}

class _ThemeDemoState extends State<ThemeDemo> {
  // The theme tint applied to the section below. Picking a new swatch rebuilds
  // the section so freshly created native views adopt the new default.
  Color _tint = const Color(0xFF6C63FF);
  bool _switch = true;
  bool _check = true;

  static const List<Color> _swatches = <Color>[
    Color(0xFF6C63FF),
    Color(0xFF0A84FF),
    Color(0xFF30D158),
    Color(0xFFFF9F0A),
    Color(0xFFFF375F),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Theme',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'LiquidGlassTheme sets app-wide defaults. The widgets below set no '
            'tint of their own — they inherit it from the theme.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Theme tint picker.
          Wrap(
            spacing: 10,
            children: _swatches.map((Color c) {
              final bool selected = c == _tint;
              return GestureDetector(
                onTap: () => setState(() => _tint = c),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.white : Colors.white24,
                      width: selected ? 3 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Everything inside inherits `_tint` with no per-widget tint set.
          LiquidGlassTheme(
            data: LiquidGlassThemeData(tint: _tint, borderRadius: 16),
            child: Column(
              key: ValueKey<Color>(_tint), // rebuild native views on tint change
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LiquidGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Themed card',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          LiquidGlassButton(label: 'Primary', onPressed: () {}),
                          const SizedBox(width: 12),
                          LiquidGlassIconButton(sfSymbol: 'star.fill', onPressed: () {}, iconColor: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LiquidGlassLabeledSwitch(
                        label: 'Enabled',
                        value: _switch,
                        onChanged: (bool v) => setState(() => _switch = v),
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      Row(
                        children: <Widget>[
                          LiquidGlassCheckbox(
                            value: _check,
                            onChanged: (bool v) => setState(() => _check = v),
                          ),
                          const SizedBox(width: 12),
                          const Text('Themed checkbox',
                              style: TextStyle(color: Colors.white, fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Accessibility',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'With respectAccessibility on (default), enable Settings ▸ '
            'Accessibility ▸ Display & Text Size ▸ Reduce Transparency to see '
            'glass surfaces turn opaque, and Reduce Motion to disable the '
            'interactive button glass.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
