import 'package:flutter/widgets.dart';
import 'package:flutter_native_view/flutter_native_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlassStyle', () {
    test('defaults', () {
      const GlassStyle style = GlassStyle();
      expect(style.cornerRadius, 20);
      expect(style.variant, GlassVariant.regular);
      expect(style.blurSigma, 18);
      expect(style.tint, isNull);
      expect(style.effectiveTint, const Color(0xFFFFFFFF));
    });

    test('clear variant softens the tint overlay', () {
      const GlassStyle regular = GlassStyle();
      const GlassStyle clear = GlassStyle(variant: GlassVariant.clear);
      expect(clear.topOpacity, lessThan(regular.topOpacity));
    });

    test('copyWith overrides only provided fields', () {
      const GlassStyle base = GlassStyle(cornerRadius: 8);
      final GlassStyle next = base.copyWith(blurSigma: 30);
      expect(next.cornerRadius, 8);
      expect(next.blurSigma, 30);
    });

    test('value equality', () {
      expect(const GlassStyle(), const GlassStyle());
      expect(
        const GlassStyle(blurSigma: 10),
        isNot(const GlassStyle(blurSigma: 20)),
      );
    });
  });
}
