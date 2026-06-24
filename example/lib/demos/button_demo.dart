import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

/// Combined showcase for all button-family components:
/// [LiquidGlassButton], [LiquidGlassIconButton] and [LiquidGlassButtonGroup].
class ButtonDemo extends StatefulWidget {
  const ButtonDemo({super.key});
  @override
  State<ButtonDemo> createState() => _ButtonDemoState();
}

class _ButtonDemoState extends State<ButtonDemo> {
  int _count = 0;
  int _likes = 0;
  String _group = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Text buttons -------------------------------------------------
          _section('Text'),
          LiquidGlassButton(
            label: 'Tapped $_count times',
            onPressed: () => setState(() => _count++),
          ),

          _section('Prefix icon'),
          LiquidGlassButton(
            label: 'Add item',
            leadingSymbol: 'plus',
            onPressed: () {},
            tint: const Color(0xFF30D158),
          ),

          _section('Suffix icon'),
          LiquidGlassButton(
            label: 'Continue',
            trailingSymbol: 'arrow.right',
            onPressed: () {},
            tint: const Color(0xFF0A84FF),
          ),

          _section('Both icons'),
          LiquidGlassButton(
            label: 'Favorite',
            leadingSymbol: 'heart.fill',
            trailingSymbol: 'chevron.right',
            onPressed: () {},
            tint: const Color(0xFFFF375F),
          ),

          // ---- Variants -----------------------------------------------------
          _section('Tinted'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              LiquidGlassButton(
                  label: 'Blue', onPressed: () {}, tint: const Color(0xFF0A84FF)),
              LiquidGlassButton(
                  label: 'Green', onPressed: () {}, tint: const Color(0xFF30D158)),
              LiquidGlassButton(
                  label: 'Purple', onPressed: () {}, tint: const Color(0xFFBF5AF2)),
            ],
          ),

          _section('Custom label color'),
          LiquidGlassButton(
            label: 'Amber text',
            onPressed: () {},
            labelColor: const Color(0xFFFFD60A),
          ),

          _section('Heading (rounded rect)'),
          LiquidGlassButton.heading(
            label: 'Get Started',
            leadingSymbol: 'sparkles',
            onPressed: () {},
            tint: const Color(0xFFFF9F0A),
          ),

          _section('Custom radius'),
          LiquidGlassButton(
            label: 'Radius 12',
            onPressed: () {},
            borderRadius: 12,
            tint: const Color(0xFFBF5AF2),
          ),

          _section('Disabled'),
          const LiquidGlassButton(label: 'Disabled', onPressed: null),

          _section('Non-interactive'),
          LiquidGlassButton(
            label: 'Static glass',
            onPressed: () {},
            interactive: false,
          ),

          // ---- Icon buttons -------------------------------------------------
          _section('Icon buttons  ·  liked $_likes'),
          Row(
            children: [
              LiquidGlassIconButton(
                sfSymbol: 'heart',
                onPressed: () => setState(() => _likes++),
              ),
              const SizedBox(width: 16),
              LiquidGlassIconButton(
                sfSymbol: 'star.fill',
                onPressed: () {},
                tint: Colors.amber,
              ),
              const SizedBox(width: 16),
              LiquidGlassIconButton(
                sfSymbol: 'trash',
                onPressed: () {},
                tint: Colors.red,
                size: 52,
                iconSize: 24,
              ),
            ],
          ),

          // ---- Button group -------------------------------------------------
          _section('Button group'
              '${_group.isEmpty ? '' : '  ·  $_group'}'),
          LiquidGlassButtonGroup(
            buttons: [
              GroupButton(
                  id: 'heart',
                  sfSymbol: 'heart',
                  onPressed: () => setState(() => _group = 'heart')),
              GroupButton(
                  id: 'star',
                  sfSymbol: 'star',
                  onPressed: () => setState(() => _group = 'star')),
              GroupButton(
                  id: 'bell',
                  sfSymbol: 'bell',
                  onPressed: () => setState(() => _group = 'bell')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      );
}
