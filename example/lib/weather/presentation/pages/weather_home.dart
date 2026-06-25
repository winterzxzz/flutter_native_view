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
                    children: const [
                      HomeTab(),
                      SettingsTab(),
                    ],
                  ),
                ),
              ),
              // Floating glass back button — replaces the nav bar so the
              // weather content runs full-bleed behind the status bar.
              if (canPop)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  child: LiquidGlassContainer(
                    borderRadius: 20,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.chevron_left,
                          color: Colors.white, size: 26),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LiquidGlassTabBar(
                  currentIndex: tabIndex,
                  brightness: themeMode == AppThemeMode.dark
                      ? Brightness.dark
                      : Brightness.light,
                  onTap: (index) => context.read<TabCubit>().switchTo(index),
                  items: const [
                    TabItem(label: 'Home', sfSymbol: 'cloud.sun'),
                    TabItem(label: 'Settings', sfSymbol: 'gearshape'),
                  ],
                ),
              ),
            ],
          ),
        );
  }
}
