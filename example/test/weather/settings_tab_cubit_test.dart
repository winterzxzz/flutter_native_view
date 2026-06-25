import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:liquid_glass_native_example/weather/shared/formatters.dart';
import 'package:liquid_glass_native_example/weather/presentation/cubit/settings_cubit.dart';
import 'package:liquid_glass_native_example/weather/presentation/cubit/tab_cubit.dart';

void main() {
  group('SettingsCubit', () {
    blocTest<SettingsCubit, TempUnit>(
      'defaults to celsius',
      build: () => SettingsCubit(),
      verify: (cubit) => expect(cubit.state, TempUnit.celsius),
    );

    blocTest<SettingsCubit, TempUnit>(
      'setUnit(fahrenheit) emits fahrenheit',
      build: () => SettingsCubit(),
      act: (cubit) => cubit.setUnit(TempUnit.fahrenheit),
      expect: () => [TempUnit.fahrenheit],
    );

    blocTest<SettingsCubit, TempUnit>(
      'setUnit(celsius) emits celsius after fahrenheit',
      build: () => SettingsCubit(),
      act: (cubit) {
        cubit.setUnit(TempUnit.fahrenheit);
        cubit.setUnit(TempUnit.celsius);
      },
      expect: () => [TempUnit.fahrenheit, TempUnit.celsius],
    );

    blocTest<SettingsCubit, TempUnit>(
      'setUnit with same value still emits (Cubit behavior)',
      build: () => SettingsCubit(),
      act: (cubit) {
        cubit.setUnit(TempUnit.celsius);
        cubit.setUnit(TempUnit.celsius);
      },
      expect: () => [TempUnit.celsius, TempUnit.celsius],
    );
  });

  group('TabCubit', () {
    blocTest<TabCubit, int>(
      'defaults to index 0',
      build: () => TabCubit(),
      verify: (cubit) => expect(cubit.state, 0),
    );

    blocTest<TabCubit, int>(
      'switchTo(1) emits 1',
      build: () => TabCubit(),
      act: (cubit) => cubit.switchTo(1),
      expect: () => [1],
    );

    blocTest<TabCubit, int>(
      'switchTo(2) then switchTo(0)',
      build: () => TabCubit(),
      act: (cubit) {
        cubit.switchTo(2);
        cubit.switchTo(0);
      },
      expect: () => [2, 0],
    );
  });
}
