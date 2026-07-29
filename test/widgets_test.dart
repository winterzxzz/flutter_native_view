import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

void main() {
  Widget app(Widget child, {LiquidGlassThemeData? theme}) {
    return MaterialApp(
      home: LiquidGlassTheme(
        data: theme ?? const LiquidGlassThemeData(),
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('public value objects', () {
    test('style and control style have structural value semantics', () {
      const LiquidGlassStyle first = LiquidGlassStyle(
        tint: Colors.blue,
        shape: LiquidGlassShape.roundedRectangle(cornerRadius: 18),
      );
      const LiquidGlassStyle second = LiquidGlassStyle(
        tint: Colors.blue,
        shape: LiquidGlassShape.roundedRectangle(cornerRadius: 18),
      );

      expect(first, second);
      expect(first.copyWith(interactive: false).interactive, isFalse);
      expect(first.withoutTint().tint, isNull);
      const LiquidGlassControlStyle control = LiquidGlassControlStyle(
        tintColor: Colors.orange,
        foregroundColor: Colors.white,
        brightness: Brightness.dark,
        size: LiquidGlassControlSize.large,
      );
      expect(control, control.copyWith());
      expect(control.copyWith(clearTintColor: true).tintColor, isNull);
      expect(
        control.copyWith(clearForegroundColor: true).foregroundColor,
        isNull,
      );
      expect(control.copyWith(clearBrightness: true).brightness, isNull);
    });

    test('invalid scalar contracts fail early', () {
      expect(
        () => LiquidGlassSlider(value: 2, min: 0, max: 1, onChanged: (_) {}),
        throwsAssertionError,
      );
      expect(
        () => LiquidGlassStepper(value: 0, step: 0, onChanged: (_) {}),
        throwsAssertionError,
      );
      expect(
        () => LiquidGlassDatePicker(
          value: DateTime(2026),
          minimumDate: DateTime(2027),
          onChanged: (_) {},
        ),
        throwsAssertionError,
      );
      expect(
        () => LiquidGlassDatePicker(value: DateTime(10000), onChanged: (_) {}),
        throwsAssertionError,
      );
    });
  });

  group('fallback controls', () {
    testWidgets('button variants and icon fallback invoke callbacks', (
      WidgetTester tester,
    ) async {
      var presses = 0;
      await tester.pumpWidget(
        app(
          Wrap(
            children: <Widget>[
              LiquidGlassButton(label: 'Standard', onPressed: () => presses++),
              LiquidGlassButton.prominent(
                label: 'Prominent',
                onPressed: () => presses++,
              ),
              LiquidGlassButton.icon(
                symbol: const LiquidGlassSymbol(
                  'heart.fill',
                  fallbackIcon: Icons.favorite,
                ),
                semanticLabel: 'Favorite',
                onPressed: () => presses++,
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Standard'));
      await tester.tap(find.text('Prominent'));
      await tester.tap(find.byIcon(Icons.favorite));
      expect(presses, 3);
    });

    testWidgets('button group routes the selected item', (
      WidgetTester tester,
    ) async {
      String? selected;
      await tester.pumpWidget(
        app(
          LiquidGlassButtonGroup(
            items: <LiquidGlassButtonItem>[
              LiquidGlassButtonItem(
                id: 'one',
                label: 'One',
                onPressed: () => selected = 'one',
              ),
              LiquidGlassButtonItem(
                id: 'two',
                label: 'Two',
                onPressed: () => selected = 'two',
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Two'));
      expect(selected, 'two');
    });

    testWidgets('controlled switch and checkbox report values', (
      WidgetTester tester,
    ) async {
      var switchValue = false;
      var checkboxValue = false;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Row(
                children: <Widget>[
                  LiquidGlassSwitch(
                    value: switchValue,
                    onChanged: (bool value) {
                      setState(() => switchValue = value);
                    },
                  ),
                  LiquidGlassCheckbox(
                    value: checkboxValue,
                    onChanged: (bool value) {
                      setState(() => checkboxValue = value);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(switchValue, isTrue);
      expect(checkboxValue, isTrue);
    });

    testWidgets('switch fallback applies semantic control size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        app(
          const LiquidGlassSwitch(
            value: false,
            onChanged: null,
            controlStyle: LiquidGlassControlStyle(
              size: LiquidGlassControlSize.compact,
            ),
          ),
        ),
      );
      final Size compact = tester.getSize(find.byType(FittedBox));

      await tester.pumpWidget(
        app(
          const LiquidGlassSwitch(
            value: false,
            onChanged: null,
            controlStyle: LiquidGlassControlStyle(
              size: LiquidGlassControlSize.large,
            ),
          ),
        ),
      );
      final Size large = tester.getSize(find.byType(FittedBox));

      expect(large.width, greaterThan(compact.width));
      expect(large.height, greaterThan(compact.height));
    });

    testWidgets(
      'fallback control style applies brightness and disabled opacity',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          app(
            const LiquidGlassSwitch(
              value: false,
              onChanged: null,
              controlStyle: LiquidGlassControlStyle(
                brightness: Brightness.dark,
                disabledOpacity: 0.2,
              ),
            ),
          ),
        );

        expect(
          tester
              .widgetList<Theme>(find.byType(Theme))
              .any((Theme theme) => theme.data.brightness == Brightness.dark),
          isTrue,
        );
        expect(
          find.byWidgetPredicate(
            (Widget widget) => widget is Opacity && widget.opacity == 0.2,
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('stepper fallback clamps non-divisible boundary steps', (
      WidgetTester tester,
    ) async {
      int? next;
      await tester.pumpWidget(
        app(
          LiquidGlassStepper(
            value: 9,
            step: 2,
            min: 0,
            max: 10,
            onChanged: (int value) => next = value,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      expect(next, 10);
    });

    for (final int year in <int>[1800, 2300]) {
      testWidgets('date fallback opens around an unbounded $year value', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          app(
            LiquidGlassDatePicker(
              value: DateTime(year, 6, 15),
              onChanged: (_) {},
            ),
          ),
        );

        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(find.byType(DatePickerDialog), findsOneWidget);
      });
    }

    testWidgets('standard-control tint styles the color fallback button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        app(
          LiquidGlassColorPicker(
            value: Colors.blue,
            onChanged: (_) {},
            controlStyle: const LiquidGlassControlStyle(
              tintColor: Colors.orange,
            ),
          ),
        ),
      );

      final FilledButton button = tester.widget<FilledButton>(
        find.byType(FilledButton),
      );
      expect(
        button.style?.backgroundColor?.resolve(<WidgetState>{}),
        Colors.orange,
      );
    });

    for (final bool supportsOpacity in <bool>[true, false]) {
      testWidgets('color fallback opacity capability is $supportsOpacity', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          app(
            LiquidGlassColorPicker(
              value: Colors.blue,
              supportsOpacity: supportsOpacity,
              onChanged: (_) {},
            ),
          ),
        );

        await tester.tap(find.byType(FilledButton).first);
        await tester.pumpAndSettle();
        expect(
          find.byType(Slider),
          supportsOpacity ? findsOneWidget : findsNothing,
        );
      });
    }

    testWidgets('generic segmented control maps index to typed value', (
      WidgetTester tester,
    ) async {
      var selected = _Period.day;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return LiquidGlassSegmentedControl<_Period>(
                segments: const <LiquidGlassSegment<_Period>>[
                  LiquidGlassSegment(value: _Period.day, label: 'Day'),
                  LiquidGlassSegment(value: _Period.week, label: 'Week'),
                ],
                value: selected,
                onChanged: (_Period value) {
                  setState(() => selected = value);
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Week'));
      await tester.pump();
      expect(selected, _Period.week);
    });

    testWidgets('typed menu maps a native/fallback index to a Dart value', (
      WidgetTester tester,
    ) async {
      _Period? selected;
      await tester.pumpWidget(
        app(
          LiquidGlassMenu<_Period>(
            label: 'Period',
            items: const <LiquidGlassMenuItem<_Period>>[
              LiquidGlassMenuItem(value: _Period.day, label: 'Day'),
              LiquidGlassMenuItem(value: _Period.week, label: 'Week'),
            ],
            onSelected: (_Period value) => selected = value,
          ),
        ),
      );

      await tester.tap(find.text('Period'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Week').last);
      await tester.pumpAndSettle();
      expect(selected, _Period.week);
    });

    testWidgets('text controller survives rebuild and live theme change', (
      WidgetTester tester,
    ) async {
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);
      var alternate = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return MaterialApp(
              home: LiquidGlassTheme(
                data: LiquidGlassThemeData(
                  style: LiquidGlassStyle(
                    tint: alternate ? Colors.blue : Colors.purple,
                  ),
                ),
                child: Scaffold(
                  body: Column(
                    children: <Widget>[
                      LiquidGlassTextField.search(controller: controller),
                      TextButton(
                        onPressed: () => setState(() => alternate = !alternate),
                        child: const Text('Theme'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );

      await tester.enterText(find.byType(TextField), 'Cupertino');
      await tester.tap(find.text('Theme'));
      await tester.pump();
      expect(controller.text, 'Cupertino');
      expect(find.text('Cupertino'), findsOneWidget);
    });

    testWidgets('diagnostics stay payload-free and idle on fallbacks', (
      WidgetTester tester,
    ) async {
      final LiquidGlassDiagnostics diagnostics = LiquidGlassDiagnostics();
      await tester.pumpWidget(
        MaterialApp(
          home: LiquidGlassTheme(
            data: const LiquidGlassThemeData(),
            diagnostics: diagnostics,
            child: LiquidGlassButton(label: 'Private value', onPressed: () {}),
          ),
        ),
      );

      expect(diagnostics.snapshot.channelOperations, 0);
      expect(diagnostics.snapshot.viewsCreated, 0);
    });
  });
}

enum _Period { day, week }
