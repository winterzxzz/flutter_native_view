import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

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
          const Text(
            'Buttons',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Native buttons with glass aesthetic.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          _ButtonCard(
            title: 'Text',
            subtitle: 'Basic text button with tap counter.',
            child: LiquidGlassButton(
              label: 'Tapped $_count times',
              onPressed: () => setState(() => _count++),
            ),
          ),

          _ButtonCard(
            title: 'Prefix Icon',
            subtitle: 'Leading SF symbol + tint.',
            child: LiquidGlassButton(
              label: 'Add item',
              leadingSymbol: 'plus',
              onPressed: () {},
              tint: const Color(0xFF30D158),
            ),
          ),

          _ButtonCard(
            title: 'Suffix Icon',
            subtitle: 'Trailing chevron for navigation cues.',
            child: LiquidGlassButton(
              label: 'Continue',
              trailingSymbol: 'arrow.right',
              onPressed: () {},
              tint: const Color(0xFF0A84FF),
            ),
          ),

          _ButtonCard(
            title: 'Both Icons',
            subtitle: 'Leading and trailing symbols combined.',
            child: LiquidGlassButton(
              label: 'Favorite',
              leadingSymbol: 'heart.fill',
              trailingSymbol: 'chevron.right',
              onPressed: () {},
              tint: const Color(0xFFFF375F),
            ),
          ),

          _ButtonCard(
            title: 'Tinted Variants',
            subtitle: 'Same style, different brand colors.',
            child: Wrap(
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
          ),

          _ButtonCard(
            title: 'Custom Label Color',
            subtitle: 'Amber text on default glass.',
            child: LiquidGlassButton(
              label: 'Amber text',
              onPressed: () {},
              labelColor: const Color(0xFFFFD60A),
            ),
          ),

          _ButtonCard(
            title: 'Heading Style',
            subtitle: 'Rounded rect for prominent CTAs.',
            child: LiquidGlassButton.heading(
              label: 'Get Started',
              leadingSymbol: 'sparkles',
              onPressed: () {},
              tint: const Color(0xFFFF9F0A),
            ),
          ),

          _ButtonCard(
            title: 'Custom Radius',
            subtitle: 'Adjust corner rounding.',
            child: LiquidGlassButton(
              label: 'Radius 12',
              onPressed: () {},
              borderRadius: 12,
              tint: const Color(0xFFBF5AF2),
            ),
          ),

          _ButtonCard(
            title: 'States',
            subtitle: 'Disabled and non-interactive variants.',
            child: Row(
              children: [
                const LiquidGlassButton(label: 'Disabled', onPressed: null),
                const SizedBox(width: 16),
                LiquidGlassButton(
                  label: 'Static',
                  onPressed: () {},
                  interactive: false,
                ),
              ],
            ),
          ),

          // Icon buttons section
          _ButtonCard(
            title: 'Icon Buttons',
            subtitle: 'liked $_likes times  ·  heart, star, trash',
            child: Row(
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
          ),

          // Button group section
          _ButtonCard(
            title: 'Button Group',
            subtitle: _group.isEmpty
                ? 'Tap a group button'
                : 'Selected: $_group',
            child: LiquidGlassButtonGroup(
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
          ),
        ],
      ),
    );
  }
}

class _ButtonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ButtonCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LiquidGlassContainer(
          tint: const Color(0xFF6C63FF),
          borderRadius: 16,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
