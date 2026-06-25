import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/app_theme.dart';

/// Cubit that manages the app appearance (light/dark backdrop).
class AppThemeCubit extends Cubit<AppThemeMode> {
  AppThemeCubit() : super(AppThemeMode.light);

  /// Sets the appearance mode.
  void setMode(AppThemeMode mode) => emit(mode);
}
