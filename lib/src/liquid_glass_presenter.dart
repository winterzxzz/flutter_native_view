import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const String _kPresenterChannel = 'flutter_native_view/presenter';

/// One selectable action in a [LiquidGlassAlert].
class AlertButton {
  const AlertButton({required this.id, required this.label, this.destructive = false});

  /// Identifier returned when this button is tapped.
  final String id;

  /// Visible button text.
  final String label;

  /// When `true`, the button is styled as a destructive action (red on iOS).
  final bool destructive;
}

/// Low-level bridge to the native presenter that drives sheets, alerts, and
/// popovers over a single method channel.
///
/// Prefer the high-level helpers ([LiquidGlassSheet], [LiquidGlassAlert],
/// [LiquidGlassPopover]); call these methods directly only when you need to
/// present without a [BuildContext]. All methods are no-ops off iOS.
class LiquidGlassPresenter {
  static final MethodChannel _channel = MethodChannel(_kPresenterChannel);

  LiquidGlassPresenter._();

  /// Presents a native sheet with the given [title].
  static Future<void> presentSheet({String title = ''}) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('presentSheet', <String, dynamic>{'title': title});
    } on MissingPluginException {
      // Ignored — non-iOS or not registered.
    }
  }

  /// Presents a native alert with [title], [message], and [buttons].
  /// Returns the id of the button that was tapped, or `null` if dismissed.
  static Future<String?> presentAlert({
    required String title,
    String message = '',
    List<AlertButton> buttons = const [],
  }) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return null;
    }
    try {
      return await _channel.invokeMethod<String>('presentAlert', <String, dynamic>{
        'title': title,
        'message': message,
        'buttons': buttons
            .map((AlertButton b) => <String, dynamic>{
                  'id': b.id,
                  'label': b.label,
                  'destructive': b.destructive,
                })
            .toList(),
      });
    } on MissingPluginException {
      return null;
    }
  }

  /// Presents a native popover with the given [title].
  static Future<void> presentPopover({String title = ''}) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('presentPopover', <String, dynamic>{'title': title});
    } on MissingPluginException {
      // Ignored — non-iOS or not registered.
    }
  }
}
