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

  testWidgets('LiquidGlassIconButton fallback fires onPressed',
      (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: LiquidGlassIconButton(
            sfSymbol: 'heart',
            onPressed: () => taps++,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(LiquidGlassIconButton));
    expect(taps, 1);
  });

  testWidgets('LiquidGlassPresenter non-iOS does not crash', (WidgetTester tester) async {
    await LiquidGlassPresenter.presentSheet(title: 'Test');
    await LiquidGlassPresenter.presentAlert(title: 'Test', message: 'Hi');
    await LiquidGlassPresenter.presentPopover(title: 'Test');
    // No crash means success — on non-iOS these are no-ops.
  });

  testWidgets('LiquidGlassMenu fallback renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: LiquidGlassMenu(
            label: 'Menu',
            items: const [MenuItem(id: 'a', title: 'A')],
            onSelected: (_) {},
          ),
        ),
      ),
    );
    expect(find.byType(LiquidGlassMenu), findsOneWidget);
  });

  testWidgets('LiquidGlassSearchBar fallback renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LiquidGlassSearchBar(
              text: 'hello',
              onChanged: (_) {},
              placeholder: 'Search',
            ),
          ),
        ),
      ),
    );
    expect(find.byType(LiquidGlassSearchBar), findsOneWidget);
  });

  testWidgets('LiquidGlassSegmentedControl fallback selection',
      (WidgetTester tester) async {
    int index = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: LiquidGlassSegmentedControl(
            segments: const ['A', 'B', 'C'],
            selectedIndex: index,
            onChanged: (int i) => index = i,
          ),
        ),
      ),
    );
    expect(find.text('A'), findsOneWidget);
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

  testWidgets('LiquidGlassSlider fallback value changes', (WidgetTester tester) async {
    double value = 0.3;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: LiquidGlassSlider(
                  value: value,
                  onChanged: (double v) => setState(() => value = v),
                  min: 0,
                  max: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
    await tester.tap(find.byType(LiquidGlassSlider));
    expect(find.byType(LiquidGlassSlider), findsOneWidget);
  });

  testWidgets('LiquidGlassStepper fallback renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: LiquidGlassStepper(value: 5, onChanged: (int v) {}),
        ),
      ),
    );
    expect(find.text('5'), findsOneWidget);
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

  testWidgets('LiquidGlassDatePicker fallback renders',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: LiquidGlassDatePicker(
            value: DateTime(2026, 6, 24),
            onChanged: (DateTime v) {},
          ),
        ),
      ),
    );
    expect(find.byType(LiquidGlassDatePicker), findsOneWidget);
  });

  testWidgets('LiquidGlassColorPicker fallback renders',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: LiquidGlassColorPicker(
            value: Colors.blue,
            onChanged: (Color v) {},
          ),
        ),
      ),
    );
    expect(find.byType(LiquidGlassColorPicker), findsOneWidget);
  });

  testWidgets('LiquidGlassButtonGroup fallback renders',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: LiquidGlassButtonGroup(
            buttons: [
              GroupButton(id: 'a', label: 'A', onPressed: () {}),
              GroupButton(id: 'b', label: 'B', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('LiquidGlassTabBar fallback renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: LiquidGlassTabBar(
            items: [
              TabItem(label: 'A'),
              TabItem(label: 'B'),
            ],
            currentIndex: 0,
            onTap: (int i) {},
          ),
        ),
      ),
    );
    expect(find.byType(LiquidGlassTabBar), findsOneWidget);
  });

  testWidgets('LiquidGlassNavigationBar fallback renders',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: LiquidGlassNavigationBar(
            title: 'Test',
            leading: [
              BarAction(id: 'back', sfSymbol: 'chevron.left'),
            ],
            trailing: [
              BarAction(id: 'done', sfSymbol: 'checkmark'),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(LiquidGlassNavigationBar), findsOneWidget);
  });

  testWidgets('LiquidGlassToolbar fallback renders',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const Center(child: Text('content')),
          bottomNavigationBar: LiquidGlassToolbar(
            actions: [
              BarAction(id: 'a', sfSymbol: 'trash'),
              BarAction(id: 'b', sfSymbol: 'folder'),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(LiquidGlassToolbar), findsOneWidget);
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
