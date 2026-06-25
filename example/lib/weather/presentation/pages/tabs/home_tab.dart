import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

import '../../cubit/settings_cubit.dart';
import '../../cubit/weather_cubit.dart';
import '../../cubit/weather_state.dart';
import '../../widgets/current_conditions_card.dart';
import '../../widgets/hourly_strip.dart';
import '../../widgets/daily_list.dart';
import '../../widgets/weather_status_view.dart';

/// Home tab: an inline search bar at the top with the forecast (or a status
/// view) below. Submitting a search loads the forecast in place — no tab
/// switch, no nav chrome.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _query = '';

  void _submit(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    FocusScope.of(context).unfocus();
    context.read<WeatherCubit>().search(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final unit = context.watch<SettingsCubit>().state;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: LiquidGlassSearchBar(
            text: _query,
            onChanged: (value) => setState(() => _query = value),
            onSubmitted: _submit,
            placeholder: 'Search a city...',
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BlocBuilder<WeatherCubit, WeatherState>(
            builder: (context, state) {
              return switch (state) {
                WeatherInitial() => const WeatherStatusView(
                    type: WeatherStatusType.empty,
                  ),
                WeatherLoading() => const WeatherStatusView(
                    type: WeatherStatusType.loading,
                  ),
                WeatherError(:final message) => WeatherStatusView(
                    type: WeatherStatusType.error,
                    message: message,
                    onRetry: context.read<WeatherCubit>().retry,
                  ),
                WeatherLoaded(:final bundle) => SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: CurrentConditionsCard(
                            weather: bundle.current,
                            location: bundle.location,
                            unit: unit,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _SectionLabel('Hourly'),
                        const SizedBox(height: 8),
                        HourlyStrip(hourly: bundle.hourly, unit: unit),
                        const SizedBox(height: 24),
                        const _SectionLabel('7-Day'),
                        const SizedBox(height: 8),
                        DailyList(daily: bundle.daily, unit: unit),
                      ],
                    ),
                  ),
              };
            },
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
