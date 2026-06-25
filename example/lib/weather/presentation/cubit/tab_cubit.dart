import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit that manages the current tab index (0..2).
class TabCubit extends Cubit<int> {
  TabCubit() : super(0);

  /// Switches to the tab at [index].
  void switchTo(int index) => emit(index);
}
