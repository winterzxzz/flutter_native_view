import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/weather_cubit.dart';
import '../../cubit/weather_state.dart';
import '../../cubit/settings_cubit.dart';
import '../../widgets/current_conditions_card.dart';
import '../../widgets/hourly_strip.dart';
import '../../widgets/daily_list.dart';
import '../../widgets/weather_status_view.dart';

/// Weather tab body: scrollable forecast or status view.
class WeatherTab extends StatelessWidget {
  const WeatherTab({super.key});

  @override
  Widget build(BuildContext context) {
    final unit = context.watch<SettingsCubit>().state;

    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        switch (state) {
          case WeatherLoaded(:final bundle):
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: CurrentConditionsCard(
                      weather: bundle.current,
                      location: bundle.location,
                      unit: unit,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      'Hourly',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  HourlyStrip(hourly: bundle.hourly, unit: unit),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      '7-Day',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DailyList(daily: bundle.daily, unit: unit),
                ],
              ),
            );

          case WeatherLoading():
            return const WeatherStatusView(type: WeatherStatusType.loading);

          case WeatherInitial():
            return const WeatherStatusView(type: WeatherStatusType.empty);

          case WeatherError(:final message):
            final cubit = context.read<WeatherCubit>();
            return WeatherStatusView(
              type: WeatherStatusType.error,
              message: message,
              onRetry: cubit.retry,
            );
        }
      },
    );
  }
}
