import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

import '../../cubit/weather_cubit.dart';
import '../../cubit/weather_state.dart';
import '../../widgets/weather_status_view.dart';

/// Search tab: city search via [LiquidGlassSearchBar].
class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: LiquidGlassSearchBar(
            text: _query,
            onChanged: (value) => setState(() => _query = value),
            onSubmitted: (value) {
              context.read<WeatherCubit>().search(value);
            },
            placeholder: 'Search a city...',
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BlocBuilder<WeatherCubit, WeatherState>(
            builder: (context, state) {
              return switch (state) {
                WeatherLoading() => const WeatherStatusView(
                    type: WeatherStatusType.loading),
                WeatherInitial() => Center(
                    child: Text(
                      'Type a city name above',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 15,
                      ),
                    ),
                  ),
                _ => const SizedBox.shrink(),
              };
            },
          ),
        ),
      ],
    );
  }
}
