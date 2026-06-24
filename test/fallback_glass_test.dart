import 'package:flutter/widgets.dart';
import 'package:flutter_native_view/flutter_native_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FallbackGlass renders its child without native code',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: FallbackGlass(
          style: GlassStyle(tint: Color(0xFF00FF00)),
          child: Text('hi'),
        ),
      ),
    );

    expect(find.text('hi'), findsOneWidget);
    expect(find.byType(DecoratedBox), findsOneWidget);
  });
}
