import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

import '../../shared/app_theme.dart';
import '../cubit/tab_cubit.dart';
import '../cubit/app_theme_cubit.dart';
import '../widgets/condition_backdrop.dart';
import 'tabs/home_tab.dart';
import 'tabs/settings_tab.dart';

class WeatherHome extends StatelessWidget {
  const WeatherHome({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppThemeCubit>().state;
    final gradient = appThemeGradient(themeMode);
    final tabIndex = context.watch<TabCubit>().state;
    final canPop = Navigator.of(context).canPop();

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          ConditionBackdrop(gradient: gradient),
          SafeArea(
            child: Padding(
              // Reserve a top strip for the floating back button so the
              // search bar / content doesn't sit underneath it.
              padding: EdgeInsets.only(top: canPop ? 48 : 0),
              child: IndexedStack(
                index: tabIndex,
                children: const [HomeTab(), SettingsTab()],
              ),
            ),
          ),
          // A standalone native icon control is appropriate here; the
          // bottom navigation remains Flutter-owned application chrome.
          if (canPop)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              child: LiquidGlassButton.icon(
                symbol: const LiquidGlassSymbol(
                  'chevron.left',
                  fallbackIcon: Icons.chevron_left,
                ),
                semanticLabel: 'Back',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NavigationBar(
              selectedIndex: tabIndex,
              onDestinationSelected: (index) =>
                  context.read<TabCubit>().switchTo(index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.cloud_outlined),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
