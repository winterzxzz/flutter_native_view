import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'presentation/cubit/weather_cubit.dart';
import 'presentation/cubit/settings_cubit.dart';
import 'presentation/cubit/tab_cubit.dart';
import 'presentation/cubit/app_theme_cubit.dart';
import 'presentation/pages/weather_home.dart';
import 'injection.dart';

/// Entry widget for the Glass Weather example app.
class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WeatherCubit>(
          create: (_) => getIt<WeatherCubit>(),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => getIt<SettingsCubit>(),
        ),
        BlocProvider<TabCubit>(
          create: (_) => getIt<TabCubit>(),
        ),
        BlocProvider<AppThemeCubit>(
          create: (_) => getIt<AppThemeCubit>(),
        ),
      ],
      // No nested MaterialApp — embed in the gallery's Navigator so the
      // floating back button can pop back to the demo list. Theme only
      // applies the Inter text theme.
      child: Theme(
        data: Theme.of(context).copyWith(
          textTheme: GoogleFonts.interTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        child: const WeatherHome(),
      ),
    );
  }
}
