import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../glass_style.dart';

/// View type id registered by the native [FlutterPlatformViewFactory].
const String kGlassSurfaceViewType = 'flutter_native_view/glass_surface';

/// Renders the native Liquid Glass surface as a decorative background.
///
/// The view never claims gestures (empty [gestureRecognizers]), so taps fall
/// through to the Flutter widgets stacked on top of it.
class GlassSurfaceView extends StatelessWidget {
  const GlassSurfaceView({super.key, required this.style});

  final GlassStyle style;

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: kGlassSurfaceViewType,
      creationParams: style.toMap(),
      creationParamsCodec: const StandardMessageCodec(),
      // Empty set => the platform view forwards all gestures to Flutter,
      // keeping the surface purely decorative.
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
    );
  }
}
