import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'liquid_glass_presenter.dart';

class LiquidGlassPopover {
  LiquidGlassPopover._();

  /// Shows a native popover via the Presenter on iOS, or a simple dialog
  /// on other platforms.
  static Future<void> show({
    required BuildContext context,
    String title = '',
  }) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await LiquidGlassPresenter.presentPopover(title: title);
    } else {
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title),
          content: const Text('Popover content'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}
