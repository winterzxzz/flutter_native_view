import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'liquid_glass_theme.dart';

const String _kTextFieldViewType = 'flutter_native_view/glass_text_field';

/// A native text input (`UITextField`) with Liquid Glass styling on iOS 26+.
///
/// On non-iOS platforms it falls back to a Material [TextField]. This is a
/// controlled field — pass the current [text] in and update your state from
/// [onChanged]. Full width with a fixed height.
class LiquidGlassTextField extends StatefulWidget {
  const LiquidGlassTextField({
    super.key,
    required this.text,
    required this.onChanged,
    this.onSubmitted,
    this.placeholder,
    this.obscureText = false,
    this.tint,
  });

  /// Current field text (controlled value).
  final String text;

  /// Called on every keystroke with the new text.
  final ValueChanged<String> onChanged;

  /// Called when the user submits (return key) with the final text.
  final ValueChanged<String>? onSubmitted;

  /// Optional greyed-out placeholder shown while the field is empty.
  final String? placeholder;

  /// When `true`, hides the entered text (e.g. for passwords).
  final bool obscureText;

  /// Optional glass tint. Falls back to the [LiquidGlassTheme] tint.
  final Color? tint;

  @override
  State<LiquidGlassTextField> createState() => _LiquidGlassTextFieldState();
}

class _LiquidGlassTextFieldState extends State<LiquidGlassTextField> {
  MethodChannel? _channel;

  Map<String, dynamic> _params() {
    final LiquidGlassThemeData t = LiquidGlassTheme.of(context);
    return <String, dynamic>{
      'text': widget.text,
      'placeholder': widget.placeholder ?? '',
      'obscureText': widget.obscureText,
      'tint': (widget.tint ?? t.tint)?.toARGB32(),
      'respectAccessibility': t.respectAccessibility,
    };
  }

  void _onCreated(int id) {
    final MethodChannel channel = MethodChannel('$_kTextFieldViewType/$id');
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onChanged':
          widget.onChanged(call.arguments as String);
        case 'onSubmitted':
          widget.onSubmitted?.call(call.arguments as String);
      }
      return null;
    });
    _channel = channel;
  }

  @override
  void didUpdateWidget(LiquidGlassTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _channel?.invokeMethod<void>('setText', widget.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return TextField(
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: widget.text,
            selection: TextSelection.collapsed(offset: widget.text.length),
          ),
        ),
        obscureText: widget.obscureText,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.placeholder,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: UiKitView(
        viewType: _kTextFieldViewType,
        creationParams: _params(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<EagerGestureRecognizer>(EagerGestureRecognizer.new),
        },
      ),
    );
  }
}
