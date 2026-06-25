import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'liquid_glass_presenter.dart';

/// Presents a native iOS alert (`UIAlertController`) with Liquid Glass chrome,
/// or a Material [AlertDialog] on other platforms.
///
/// This is a static presenter, not a widget — call [show] from an event
/// handler and await the id of the button the user tapped.
class LiquidGlassAlert {
  LiquidGlassAlert._();

  /// Shows a native alert via the Presenter on iOS, or a Material [showDialog]
  /// on other platforms. Returns the id of the tapped button, or `null` if the
  /// alert was dismissed without a selection.
  ///
  /// [context] is used only for the non-iOS [showDialog] fallback. [title] is
  /// required; [message] is an optional body. [buttons] are the selectable
  /// actions, each carrying the id returned by this method.
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
