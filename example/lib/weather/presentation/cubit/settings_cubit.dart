import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/formatters.dart';

/// Cubit that manages the temperature unit preference.
class SettingsCubit extends Cubit<TempUnit> {
  SettingsCubit() : super(TempUnit.celsius);

  /// Sets the temperature unit.
  void setUnit(TempUnit unit) => emit(unit);
}
