import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_native/src/text_editing_reconciliation.dart';

void main() {
  test('native insertion advances selection instead of collapsing to end', () {
    const TextEditingValue previous = TextEditingValue(
      text: 'abcd',
      selection: TextSelection.collapsed(offset: 2),
    );

    final TextEditingValue next = reconcileNativeTextEditingValue(
      previous,
      'abXcd',
    );

    expect(next.text, 'abXcd');
    expect(next.selection, const TextSelection.collapsed(offset: 3));
  });

  test('native edit preserves selection and composing ranges after edit', () {
    const TextEditingValue previous = TextEditingValue(
      text: 'hello world',
      selection: TextSelection(baseOffset: 8, extentOffset: 11),
      composing: TextRange(start: 6, end: 11),
    );

    final TextEditingValue next = reconcileNativeTextEditingValue(
      previous,
      'hello! world',
    );

    expect(
      next.selection,
      const TextSelection(baseOffset: 9, extentOffset: 12),
    );
    expect(next.composing, const TextRange(start: 7, end: 12));
  });
}
