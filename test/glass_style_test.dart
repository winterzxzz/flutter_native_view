import 'package:flutter/widgets.dart';
import 'package:flutter_native_view/flutter_native_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlassStyle', () {
    test('defaults', () {
      const GlassStyle style = GlassStyle();
      expect(style.cornerRadius, 20);
      expect(style.variant, GlassVariant.regular);
      expect(style.tint, isNull);
    });

    test('toMap serializes tint as ARGB32 and variant by name', () {
      const GlassStyle style = GlassStyle(
        tint: Color(0xFF112233),
        cornerRadius: 12,
        variant: GlassVariant.clear,
      );
      final Map<String, dynamic> map = style.toMap();
      expect(map['tintColor'], 0xFF112233);
      expect(map['cornerRadius'], 12);
      expect(map['variant'], 'clear');
    });

    test('toMap keeps null tint as null', () {
      expect(const GlassStyle().toMap()['tintColor'], isNull);
    });

    test('copyWith overrides only provided fields', () {
      const GlassStyle base = GlassStyle(cornerRadius: 8);
      final GlassStyle next = base.copyWith(variant: GlassVariant.clear);
      expect(next.cornerRadius, 8);
      expect(next.variant, GlassVariant.clear);
    });

    test('value equality', () {
      expect(const GlassStyle(), const GlassStyle());
      expect(
        const GlassStyle(cornerRadius: 10),
        isNot(const GlassStyle(cornerRadius: 20)),
      );
    });
  });
}
