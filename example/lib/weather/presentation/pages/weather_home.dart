import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

import '../../shared/weather_codes.dart';
import '../cubit/weather_cubit.dart';
import '../cubit/weather_state.dart';
import '../cubit/tab_cubit.dart';
import '../widgets/condition_backdrop.dart';
import 'tabs/weather_tab.dart';
import 'tabs/search_tab.dart';
import 'tabs/settings_tab.dart';

class WeatherHome extends StatelessWidget {
  const WeatherHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<WeatherCubit, WeatherState>(
      listener: (context, state) {
        if (state is WeatherLoaded) {
          context.read<TabCubit>().switchTo(0);
        }
      },
      child: BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, state) {
          final gradient = switch (state) {
            WeatherLoaded(:final bundle) => weatherVisualFromCode(
              bundle.current.weatherCode,
              bundle.current.isDay,
            ).gradient,
            _ => weatherVisualFromCode(0, true).gradient,
          };

          final tabIndex = context.watch<TabCubit>().state;

          return Stack(
            children: [
              ConditionBackdrop(gradient: gradient),
              SafeArea(
                child: IndexedStack(
                  index: tabIndex,
                  children: const [
                    WeatherTab(),
                    SearchTab(),
                    SettingsTab(),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LiquidGlassTabBar(
                  currentIndex: tabIndex,
                  onTap: (index) => context.read<TabCubit>().switchTo(index),
                  items: const [
                    TabItem(label: 'Weather', sfSymbol: 'cloud.sun'),
                    TabItem(label: 'Search', sfSymbol: 'magnifyingglass'),
                    TabItem(label: 'Settings', sfSymbol: 'gearshape'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
