import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

import 'demos/activity_indicator_demo.dart';
import 'demos/button_demo.dart';
import 'demos/card_demo.dart';
import 'demos/color_picker_demo.dart';
import 'demos/container_demo.dart';
import 'demos/date_picker_demo.dart';
import 'demos/menu_demo.dart';
import 'demos/navigation_bar_demo.dart';
import 'demos/progress_view_demo.dart';
import 'demos/search_bar_demo.dart';
import 'demos/segmented_demo.dart';
import 'demos/slider_demo.dart';
import 'demos/stepper_demo.dart';
import 'demos/switch_demo.dart';
import 'demos/tab_bar_demo.dart';
import 'demos/text_field_demo.dart';
import 'demos/theme_demo.dart';
import 'demos/toolbar_demo.dart';

typedef DemoBuilder = Widget Function();

class DemoEntry {
  const DemoEntry(this.title, this.builder);
  final String title;
  final DemoBuilder builder;
}

final List<DemoEntry> demos = <DemoEntry>[
  DemoEntry('ActivityIndicator', () => buildActivityIndicatorDemo()),
  DemoEntry('Buttons', () => const ButtonDemo()),
  DemoEntry('Card', () => buildCardDemo()),
  DemoEntry('ColorPicker', () => buildColorPickerDemo()),
  DemoEntry('Container', () => buildContainerDemo()),
  DemoEntry('DatePicker', () => buildDatePickerDemo()),
  DemoEntry('Menu', () => const MenuDemo()),
  DemoEntry('NavigationBar', () => buildNavigationBarDemo()),
  DemoEntry('ProgressView', () => buildProgressViewDemo()),
  DemoEntry('SearchBar', () => const SearchBarDemo()),
  DemoEntry('SegmentedControl', () => const SegmentedDemo()),
  DemoEntry('Slider', () => buildSliderDemo()),
  DemoEntry('Stepper', () => buildStepperDemo()),
  DemoEntry('Switch', () => const SwitchDemo()),
  DemoEntry('TabBar', () => buildTabBarDemo()),
  DemoEntry('TextField', () => buildTextFieldDemo()),
  DemoEntry('Theme & A11y', () => buildThemeDemo()),
  DemoEntry('Toolbar', () => buildToolbarDemo()),
];

class Gallery extends StatelessWidget {
  const Gallery({super.key});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassTheme(
      data: const LiquidGlassThemeData(tint: Color(0xFF6C63FF), borderRadius: 14),
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1B1530),
                Color(0xFF0E1426),
                Color(0xFF06121A),
              ],
            ),
          ),
          child: Column(
            children: [
              LiquidGlassNavigationBar(title: 'Liquid Glass Gallery'),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: demos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int i) {
                      final DemoEntry entry = demos[i];
                      return _DemoCard(
                        title: entry.title,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => _DemoPage(
                              title: entry.title,
                              child: entry.builder(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _DemoCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Use pure Flutter rendering here — not LiquidGlassContainer (UiKitView).
    // Platform views inside a recycling ListView get torn down/recreated on
    // scroll, causing items to flicker and lose their background (the "crack").
    // A Flutter-rendered glassmorphism look is stable in a scroll view; keep the
    // native LiquidGlassContainer for one-off, non-recycled surfaces.
    const Color tint = Color(0xFF6C63FF);
    final BorderRadius radius = BorderRadius.circular(16);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          // Frosted glass: blurs whatever sits behind the card (the gradient).
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              // Top-down highlight gradient sells the "lit glass" surface.
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  tint.withValues(alpha: 0.14),
                  Colors.white.withValues(alpha: 0.04),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoPage extends StatelessWidget {
  final String title;
  final Widget child;

  const _DemoPage({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassTheme(
      data: const LiquidGlassThemeData(tint: Color(0xFF6C63FF), borderRadius: 14),
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1B1530),
                Color(0xFF0E1426),
                Color(0xFF06121A),
              ],
            ),
          ),
          child: Column(
            children: [
              LiquidGlassNavigationBar(
                title: title,
                leading: [
                  BarAction(
                    id: 'back',
                    sfSymbol: 'chevron.left',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Center(child: child),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
