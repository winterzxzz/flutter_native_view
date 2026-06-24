import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LiquidGlass renders its child', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: LiquidGlass(child: Text('hello'))),
      ),
    );
    expect(find.text('hello'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('LiquidGlassButton fires onPressed', (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: LiquidGlassButton(
            onPressed: () => taps++,
            child: const Text('tap'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('tap'));
    expect(taps, 1);
  });

  testWidgets('LiquidGlassSwitch toggles', (WidgetTester tester) async {
    bool value = false;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return MaterialApp(
            home: Center(
              child: LiquidGlassSwitch(
                value: value,
                onChanged: (bool v) => setState(() => value = v),
              ),
            ),
          );
        },
      ),
    );
    await tester.tap(find.byType(LiquidGlassSwitch));
    await tester.pumpAndSettle();
    expect(value, isTrue);
  });
}
