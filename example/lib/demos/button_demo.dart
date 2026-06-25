import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

/// Debug-only: counts how many times each card has rebuilt, keyed by title.
/// Lets us see whether a single tap rebuilds one card or the whole page.
final Map<String, int> _cardBuildCounts = <String, int>{};

class ButtonDemo extends StatelessWidget {
  const ButtonDemo({super.key});

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

          // Stateful pieces are isolated into their own widgets so a tap only
          // rebuilds that one card — not every glass platform view on the page,
          // which would cause a full-page repaint flash.
          const _CounterButtonCard(),

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
          const _IconButtonsCard(),

          // Button group section
          const _ButtonGroupCard(),
        ],
      ),
    );
  }
}

class _CounterButtonCard extends StatefulWidget {
  const _CounterButtonCard();
  @override
  State<_CounterButtonCard> createState() => _CounterButtonCardState();
}

class _CounterButtonCardState extends State<_CounterButtonCard> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return _ButtonCard(
      title: 'Text',
      subtitle: 'Basic text button with tap counter.',
      child: LiquidGlassButton(
        label: 'Tapped $_count times',
        onPressed: () => setState(() => _count++),
      ),
    );
  }
}

class _IconButtonsCard extends StatefulWidget {
  const _IconButtonsCard();
  @override
  State<_IconButtonsCard> createState() => _IconButtonsCardState();
}

class _IconButtonsCardState extends State<_IconButtonsCard> {
  int _likes = 0;

  @override
  Widget build(BuildContext context) {
    return _ButtonCard(
      title: 'Icon Buttons',
      subtitle: 'liked $_likes times  ·  heart, star, trash',
      child: Row(
        children: [
          LiquidGlassIconButton(
            sfSymbol: 'heart',
            onPressed: () => setState(() => _likes++),
            iconColor: Colors.white,
          ),
          const SizedBox(width: 16),
          LiquidGlassIconButton(
            sfSymbol: 'star.fill',
            onPressed: () {},
            tint: Colors.amber,
            iconColor: Colors.white,
          ),
          const SizedBox(width: 16),
          LiquidGlassIconButton(
            sfSymbol: 'trash',
            onPressed: () {},
            tint: Colors.red,
            iconColor: Colors.white,
            size: 52,
            iconSize: 24,
          ),
        ],
      ),
    );
  }
}

class _ButtonGroupCard extends StatefulWidget {
  const _ButtonGroupCard();
  @override
  State<_ButtonGroupCard> createState() => _ButtonGroupCardState();
}

class _ButtonGroupCardState extends State<_ButtonGroupCard> {
  String _group = '';

  @override
  Widget build(BuildContext context) {
    return _ButtonCard(
      title: 'Button Group',
      subtitle: _group.isEmpty ? 'Tap a group button' : 'Selected: $_group',
      child: LiquidGlassButtonGroup(
        spacing: 12,
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
    if (kDebugMode) {
      final int n = (_cardBuildCounts[title] ?? 0) + 1;
      _cardBuildCounts[title] = n;
      debugPrint('[Card "$title"] build #$n');
    }
    const Color tint = Color(0xFF6C63FF);
    final BorderRadius radius = BorderRadius.circular(16);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      // Static translucent glass for the card chrome — NO BackdropFilter.
      // A live backdrop blur re-samples whatever is behind it on every relayout;
      // while the native buttons measure themselves and resize on first open,
      // that re-sampling makes the card background flicker and the button glass
      // shift color. A fixed gradient never re-samples, so it stays rock-stable.
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.14),
                tint.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
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
