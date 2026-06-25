import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'liquid_glass_presenter.dart';

/// Presents a native iOS sheet (`UISheetPresentationController`) with Liquid
/// Glass chrome, or a Material bottom sheet on other platforms.
///
/// This is a static presenter, not a widget — call [show] from an event
/// handler.
class LiquidGlassSheet {
  LiquidGlassSheet._();

  /// Shows a native sheet via the Presenter on iOS, or a Material
  /// [showModalBottomSheet] on other platforms.
  ///
  /// [context] is used only for the non-iOS fallback. [title] is the sheet's
  /// heading text.
  static Future<void> show({
    required BuildContext context,
    String title = '',
  }) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await LiquidGlassPresenter.presentSheet(title: title);
    } else {
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
