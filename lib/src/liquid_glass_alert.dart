import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'liquid_glass_presenter.dart';

class LiquidGlassAlert {
  LiquidGlassAlert._();

  /// Shows a native alert via the Presenter on iOS, or a Material [showDialog]
  /// on other platforms. Returns the id of the tapped button.
  static Future<String?> show({
    required BuildContext context,
    required String title,
    String message = '',
    List<AlertButton> buttons = const [],
  }) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return LiquidGlassPresenter.presentAlert(
        title: title,
        message: message,
        buttons: buttons,
      );
    } else {
      return showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title),
          content: message.isNotEmpty ? Text(message) : null,
          actions: buttons
              .map(
                (AlertButton b) => TextButton(
                  onPressed: () => Navigator.pop(context, b.id),
                  child: Text(b.label),
                ),
              )
              .toList(),
        ),
      );
    }
  }
}
