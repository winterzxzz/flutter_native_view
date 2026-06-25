import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';

const String _kSearchBarViewType = 'flutter_native_view/glass_search_bar';

/// A native iOS search field (`UISearchTextField`) with Liquid Glass styling on
/// iOS 26+. On non-iOS platforms it falls back to a Material [TextField].
///
/// This is a controlled field: pass the current [text] in and update your state
/// from [onChanged]. The native field is full width with a fixed height.
class LiquidGlassSearchBar extends StatefulWidget {
  const LiquidGlassSearchBar({
    super.key,
    required this.text,
    required this.onChanged,
    this.onSubmitted,
    this.placeholder,
    this.textColor,
    this.iconColor,
    this.cursorColor,
    this.height = 44,
  });

  /// Current query text shown in the field (controlled value).
  final String text;

  /// Called on every keystroke with the new query text.
  final ValueChanged<String> onChanged;

  /// Called when the user submits (return key) with the final query text.
  final ValueChanged<String>? onSubmitted;

  /// Optional greyed-out placeholder shown while the field is empty.
  final String? placeholder;

  /// Color of the typed text. Defaults to white (suits a dark glass surface).
  final Color? textColor;

  /// Color of the leading magnifying-glass icon. Defaults to [textColor] at
  /// 70% opacity.
  final Color? iconColor;

  /// Color of the text cursor / selection tint. Defaults to [textColor].
  final Color? cursorColor;

  /// Field height. Defaults to 44. Width always fills the parent.
  final double height;

  @override
  State<LiquidGlassSearchBar> createState() => _LiquidGlassSearchBarState();
}

class _LiquidGlassSearchBarState extends State<LiquidGlassSearchBar>
    with GlassPlatformViewMixin<LiquidGlassSearchBar> {
  @override
  String get glassViewType => _kSearchBarViewType;

  Color get _textColor => widget.textColor ?? Colors.white;
  Color get _iconColor => widget.iconColor ?? _textColor.withValues(alpha: 0.7);
  Color get _cursorColor => widget.cursorColor ?? _textColor;

  @override
  Map<String, dynamic> buildParams() => <String, dynamic>{
        'text': widget.text,
        'placeholder': widget.placeholder ?? '',
        'textColor': _textColor.toARGB32(),
        'iconColor': _iconColor.toARGB32(),
        'cursorColor': _cursorColor.toARGB32(),
      };

  @override
  Future<dynamic> handleCall(MethodCall call) async {
    switch (call.method) {
      case 'onChanged':
        widget.onChanged(call.arguments as String);
      case 'onSubmitted':
        widget.onSubmitted?.call(call.arguments as String);
    }
    return null;
  }

  @override
  void didUpdateWidget(LiquidGlassSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Lightweight text-only sync; see LiquidGlassTextField for the rationale.
    if (oldWidget.text != widget.text) {
      channel?.invokeMethod<void>('setText', widget.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isGlassPlatform) {
      return TextField(
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: widget.text,
            selection: TextSelection.collapsed(offset: widget.text.length),
          ),
        ),
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: TextStyle(color: _textColor),
        cursorColor: _cursorColor,
        decoration: InputDecoration(
          hintText: widget.placeholder,
          hintStyle: TextStyle(color: _iconColor),
          prefixIcon: Icon(Icons.search, color: _iconColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );
    }
    return glassView(
      width: double.infinity,
      height: widget.height,
      gesture: GlassGesture.eager,
    );
  }
}
