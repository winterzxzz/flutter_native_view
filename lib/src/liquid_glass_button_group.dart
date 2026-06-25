import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_button.dart';

const String _kButtonGroupViewType = 'flutter_native_view/glass_button_group';

/// A group of glass buttons sharing one `GlassEffectContainer` on iOS 26+.
///
/// On non-iOS platforms it falls back to a [Row] of [LiquidGlassButton].
class LiquidGlassButtonGroup extends StatefulWidget {
  const LiquidGlassButtonGroup({
    super.key,
    required this.buttons,
    this.spacing = 8,
  });

  final List<GroupButton> buttons;

  /// Spacing between buttons inside the group. Defaults to 8.
  final double spacing;

  @override
  State<LiquidGlassButtonGroup> createState() => _LiquidGlassButtonGroupState();
}

/// A single button definition inside a [LiquidGlassButtonGroup].
class GroupButton {
  const GroupButton({
    required this.id,
    this.label,
    this.sfSymbol,
    this.onPressed,
  });

  final String id;
  final String? label;
  final String? sfSymbol;
  final VoidCallback? onPressed;
}

class _LiquidGlassButtonGroupState extends State<LiquidGlassButtonGroup>
    with GlassPlatformViewMixin<LiquidGlassButtonGroup> {
  @override
  String get glassViewType => _kButtonGroupViewType;

  @override
  bool get measuresSize => true;

  Map<String, VoidCallback> get _callbacks => <String, VoidCallback>{
        for (final GroupButton b in widget.buttons) b.id: b.onPressed ?? () {},
      };

  @override
  Map<String, dynamic> buildParams() => <String, dynamic>{
        'buttons': widget.buttons
            .map((GroupButton b) => <String, dynamic>{
                  'id': b.id,
                  'label': b.label,
                  'sfSymbol': b.sfSymbol,
                })
            .toList(growable: false),
        'spacing': widget.spacing,
      };

  @override
  Future<dynamic> handleCall(MethodCall call) async {
    if (call.method == 'onPressed') {
      final String? buttonId = call.arguments as String?;
      if (buttonId != null) _callbacks[buttonId]?.call();
    }
    return null;
  }

  @override
  void didUpdateWidget(LiquidGlassButtonGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncConfig();
  }

  @override
  Widget build(BuildContext context) {
    if (!isGlassPlatform) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.buttons
            .map((GroupButton b) => LiquidGlassButton(
                  label: b.label ?? '',
                  onPressed: b.onPressed,
                ))
            .toList(growable: false),
      );
    }
    return glassView(estimatedSize: const Size(200, 44));
  }
}
