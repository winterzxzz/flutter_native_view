import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

import '../../cubit/settings_cubit.dart';
import '../../cubit/app_theme_cubit.dart';
import '../../../shared/app_theme.dart';
import '../../../shared/formatters.dart';

/// Settings tab: temperature unit toggle and about info.
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final unit = context.watch<SettingsCubit>().state;
    final selectedIndex = unit == TempUnit.celsius ? 0 : 1;
    final themeMode = context.watch<AppThemeCubit>().state;
    final themeIndex = themeMode == AppThemeMode.light ? 0 : 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Temperature Unit',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          LiquidGlassSegmentedControl(
            segments: const ['°C', '°F'],
            selectedIndex: selectedIndex,
            onChanged: (index) {
              context.read<SettingsCubit>().setUnit(
                    index == 0 ? TempUnit.celsius : TempUnit.fahrenheit,
                  );
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'Appearance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          LiquidGlassSegmentedControl(
            segments: const ['Light', 'Dark'],
            selectedIndex: themeIndex,
            onChanged: (index) {
              context.read<AppThemeCubit>().setMode(
                    index == 0 ? AppThemeMode.light : AppThemeMode.dark,
                  );
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'About',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _aboutRow('Weather Data', 'Open-Meteo'),
                const Divider(color: Colors.white12),
                _aboutRow('Built with', 'liquid_glass_native'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
