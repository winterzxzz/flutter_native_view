import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_native/src/glass_config_tracker.dart';
import 'package:liquid_glass_native/src/glass_platform_view.dart';

void main() {
  test('structurally equal nested snapshots do not send updates', () {
    final GlassConfigTracker tracker = GlassConfigTracker()
      ..initialize(<String, Object?>{
        'value': false,
        'items': <Object?>[
          <String, Object?>{'id': 'a', 'label': 'A'},
        ],
      });

    expect(
      tracker.shouldSend(<String, Object?>{
        'value': false,
        'items': <Object?>[
          <String, Object?>{'id': 'a', 'label': 'A'},
        ],
      }),
      isFalse,
    );
  });

  test('native state patch suppresses a controlled-widget echo', () {
    final GlassConfigTracker tracker = GlassConfigTracker()
      ..initialize(<String, Object?>{'value': false, 'tint': 1})
      ..acceptNativeState(<String, Object?>{'value': true});

    expect(
      tracker.shouldSend(<String, Object?>{'value': true, 'tint': 1}),
      isFalse,
    );
    expect(
      tracker.shouldSend(<String, Object?>{'value': true, 'tint': 2}),
      isTrue,
    );
  });

  for (final ({String name, String key, Object oldValue, Object nativeValue})
      testCase
      in <({String name, String key, Object oldValue, Object nativeValue})>[
        (name: 'switch', key: 'value', oldValue: false, nativeValue: true),
        (name: 'checkbox', key: 'value', oldValue: false, nativeValue: true),
        (name: 'slider', key: 'value', oldValue: 0.2, nativeValue: 0.8),
        (name: 'stepper', key: 'value', oldValue: 1, nativeValue: 2),
        (name: 'segmented', key: 'selectedIndex', oldValue: 0, nativeValue: 1),
        (name: 'date', key: 'value', oldValue: 1000, nativeValue: 2000),
        (
          name: 'color',
          key: 'value',
          oldValue: 0xFF000000,
          nativeValue: 0xFFFFFFFF,
        ),
      ]) {
    test('${testCase.name} rejected native value reconciles to Dart', () {
      final Map<String, Object?> authoritative = <String, Object?>{
        testCase.key: testCase.oldValue,
      };
      final GlassConfigTracker tracker = GlassConfigTracker()
        ..initialize(authoritative)
        ..acceptNativeState(<String, Object?>{
          testCase.key: testCase.nativeValue,
        });

      expect(tracker.shouldSend(authoritative), isTrue);
    });
  }

  test('snapshots are defensively frozen against caller mutation', () {
    final List<Object?> items = <Object?>['A'];
    final GlassConfigTracker tracker = GlassConfigTracker()
      ..initialize(<String, Object?>{'items': items});
    items.add('B');

    expect(
      tracker.shouldSend(<String, Object?>{
        'items': <Object?>['A'],
      }),
      isFalse,
    );
  });

  test('same-frame sync requests coalesce into one flush', () {
    final GlassFrameSyncCoordinator coordinator = GlassFrameSyncCoordinator();
    final List<void Function()> queued = <void Function()>[];
    var flushes = 0;

    expect(
      coordinator.schedule(enqueue: queued.add, flush: () => flushes++),
      isTrue,
    );
    expect(
      coordinator.schedule(enqueue: queued.add, flush: () => flushes++),
      isFalse,
    );
    expect(queued, hasLength(1));
    queued.single();
    expect(flushes, 1);

    expect(
      coordinator.schedule(enqueue: queued.add, flush: () => flushes++),
      isTrue,
    );
  });

  test('creation snapshot does not hide a newer current configuration', () {
    final GlassConfigTracker tracker = GlassConfigTracker()
      ..initialize(<String, Object?>{'value': false});

    expect(tracker.shouldSend(<String, Object?>{'value': true}), isTrue);
  });

  test('only native iOS uses UIKit platform views', () {
    expect(
      isGlassPlatformFor(platform: TargetPlatform.iOS, isWeb: false),
      isTrue,
    );
    expect(
      isGlassPlatformFor(platform: TargetPlatform.iOS, isWeb: true),
      isFalse,
    );
    expect(
      isGlassPlatformFor(platform: TargetPlatform.macOS, isWeb: false),
      isFalse,
    );
  });

  testWidgets('rejected native value is sent back after the frame', (
    WidgetTester tester,
  ) async {
    const MethodChannel channel = MethodChannel('test/controlled/7');
    final List<MethodCall> calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall call,
    ) async {
      calls.add(call);
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    final GlobalKey<_ControlledHarnessState> key =
        GlobalKey<_ControlledHarnessState>();

    await tester.pumpWidget(_ControlledHarness(key: key, value: false));
    await key.currentState!.connect();
    key.currentState!.acceptNativeValue(true);
    await tester.pump();

    expect(calls, hasLength(1));
    expect(calls.single.method, 'updateConfig');
    expect((calls.single.arguments as Map<Object?, Object?>)['value'], isFalse);
  });

  testWidgets('accepted native value is not echoed after parent rebuild', (
    WidgetTester tester,
  ) async {
    const MethodChannel channel = MethodChannel('test/controlled/7');
    final List<MethodCall> calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall call,
    ) async {
      calls.add(call);
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    final GlobalKey<_ControlledHarnessState> key =
        GlobalKey<_ControlledHarnessState>();

    await tester.pumpWidget(_ControlledHarness(key: key, value: false));
    await key.currentState!.connect();
    key.currentState!.acceptNativeValue(true);
    await tester.pumpWidget(_ControlledHarness(key: key, value: true));
    await tester.pump();

    expect(calls, isEmpty);
  });
}

class _ControlledHarness extends StatefulWidget {
  const _ControlledHarness({super.key, required this.value});

  final bool value;

  @override
  State<_ControlledHarness> createState() => _ControlledHarnessState();
}

class _ControlledHarnessState extends State<_ControlledHarness>
    with GlassPlatformViewMixin<_ControlledHarness> {
  @override
  String get glassViewType => 'test/controlled';

  @override
  Map<String, Object?> buildParams() => <String, Object?>{
    'value': widget.value,
  };

  Future<void> connect() => onGlassViewCreated(7, buildParams());

  void acceptNativeValue(bool value) {
    dispatchControlledNativeState(<String, Object?>{'value': value}, () {});
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}
