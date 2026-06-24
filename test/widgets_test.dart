import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';
import 'package:flutter_test/flutter_test.dart';

// On the test host (non-iOS) the widgets render their Material fallbacks, which
// is what these tests exercise. The native glass path is verified on an iOS 26
// simulator.
void main() {
  testWidgets('LiquidGlassButton fallback fires onPressed',
      (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: LiquidGlassButton(
            label: 'Tap',
            onPressed: () => taps++,
          ),
        ),
      ),
    );
    expect(find.text('Tap'), findsOneWidget);
    await tester.tap(find.byType(LiquidGlassButton));
    expect(taps, 1);
  });

  testWidgets('LiquidGlassButton.heading builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: LiquidGlassButton.heading(label: 'Hi', onPressed: () {}),
        ),
      ),
    );
    expect(find.text('Hi'), findsOneWidget);
  });

  testWidgets('LiquidGlassContainer fallback renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: LiquidGlassContainer(),
          ),
        ),
      ),
    );
    expect(find.byType(LiquidGlassContainer), findsOneWidget);
  });

  testWidgets('LiquidGlassActivityIndicator fallback renders',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: LiquidGlassActivityIndicator(size: 48),
        ),
      ),
    );
    expect(find.byType(LiquidGlassActivityIndicator), findsOneWidget);
  });

  testWidgets('LiquidGlassProgressView fallback renders',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: LiquidGlassProgressView(value: 0.5),
        ),
      ),
    );
    expect(find.byType(LiquidGlassProgressView), findsOneWidget);
  });

  testWidgets('LiquidGlassSwitch fallback toggles', (WidgetTester tester) async {
    bool value = false;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: LiquidGlassSwitch(
                  value: value,
                  onChanged: (bool v) => setState(() => value = v),
                ),
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
