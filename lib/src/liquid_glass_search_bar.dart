import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  });

  /// Current query text shown in the field (controlled value).
  final String text;

  /// Called on every keystroke with the new query text.
  final ValueChanged<String> onChanged;

  /// Called when the user submits (return key) with the final query text.
  final ValueChanged<String>? onSubmitted;

  /// Optional greyed-out placeholder shown while the field is empty.
  final String? placeholder;

  @override
  State<LiquidGlassSearchBar> createState() => _LiquidGlassSearchBarState();
}

class _LiquidGlassSearchBarState extends State<LiquidGlassSearchBar> {
  MethodChannel? _channel;

  Map<String, dynamic> _params() => <String, dynamic>{
        'text': widget.text,
        'placeholder': widget.placeholder ?? '',
      };

  void _onCreated(int id) {
    final MethodChannel channel = MethodChannel('$_kSearchBarViewType/$id');
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
  void didUpdateWidget(LiquidGlassSearchBar oldWidget) {
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
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.placeholder,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: UiKitView(
        viewType: _kSearchBarViewType,
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
