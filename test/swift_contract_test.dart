import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('custom-surface fallback is opaque and material-backed', () {
    final String source = File(
      'ios/Classes/GlassPlatformView.swift',
    ).readAsStringSync();

    expect(source, contains('withAlphaComponent(1)'));
    expect(source, contains('.fill(.ultraThinMaterial)'));
  });

  test('standard native controls do not parse unused glass style', () {
    for (final String name in <String>[
      'GlassToggleView.swift',
      'GlassSliderView.swift',
      'GlassStepperView.swift',
      'GlassSegmentedView.swift',
      'GlassDatePickerView.swift',
      'GlassColorPickerView.swift',
    ]) {
      final String source = File('ios/Classes/$name').readAsStringSync();
      expect(
        source,
        isNot(contains('GlassStyleConfiguration')),
        reason: '$name must not silently accept custom glass configuration.',
      );
    }
  });

  test('native text configuration exposes one autocorrection capability', () {
    final String source = File(
      'ios/Classes/GlassTextFieldView.swift',
    ).readAsStringSync();

    expect(
      source,
      contains('disableAutocorrection(!model.configuration.autocorrect)'),
    );
    expect(source, isNot(contains('enableSuggestions')));
  });
}
