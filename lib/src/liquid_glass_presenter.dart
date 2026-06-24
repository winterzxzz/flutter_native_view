import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const String _kPresenterChannel = 'flutter_native_view/presenter';

class AlertButton {
  const AlertButton({required this.id, required this.label, this.destructive = false});

  final String id;
  final String label;
  final bool destructive;
}

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
