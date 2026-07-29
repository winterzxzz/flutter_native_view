import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_platform_view.dart';
import 'liquid_glass_style.dart';
import 'text_editing_reconciliation.dart';

const String _kTextFieldViewType = 'liquid_glass_native/text_field';

enum LiquidGlassKeyboardType { text, emailAddress, number, decimal, phone, url }

enum LiquidGlassTextCapitalization { none, words, sentences, characters }

enum LiquidGlassSubmitAction { done, go, next, search, send }

/// Typed text-input behavior shared by native and fallback fields.
@immutable
final class LiquidGlassTextInputConfiguration {
  const LiquidGlassTextInputConfiguration({
    this.keyboardType = LiquidGlassKeyboardType.text,
    this.capitalization = LiquidGlassTextCapitalization.sentences,
    this.submitAction = LiquidGlassSubmitAction.done,
    this.autocorrect = true,
  });

  final LiquidGlassKeyboardType keyboardType;
  final LiquidGlassTextCapitalization capitalization;
  final LiquidGlassSubmitAction submitAction;

  /// Enables the platform's combined autocorrection and suggestion behavior.
  /// SwiftUI does not expose independent suggestion control on every supported
  /// iOS version, so v1 deliberately models this as one capability.
  final bool autocorrect;

  @override
  bool operator ==(Object other) =>
      other is LiquidGlassTextInputConfiguration &&
      other.keyboardType == keyboardType &&
      other.capitalization == capitalization &&
      other.submitAction == submitAction &&
      other.autocorrect == autocorrect;

  @override
  int get hashCode =>
      Object.hash(keyboardType, capitalization, submitAction, autocorrect);
}

/// A stable controller-backed native text field with Liquid Glass on iOS 26+.
class LiquidGlassTextField extends StatefulWidget {
  const LiquidGlassTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.placeholder,
    this.obscureText = false,
    this.enabled = true,
    this.configuration = const LiquidGlassTextInputConfiguration(),
    this.style,
    this.controlStyle,
    this.semanticLabel,
  }) : isSearch = false,
       assert(controller == null || initialValue == null);

  /// A search field with a native magnifying-glass affordance and search
  /// submit action.
  const LiquidGlassTextField.search({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.placeholder = 'Search',
    this.enabled = true,
    this.configuration = const LiquidGlassTextInputConfiguration(
      capitalization: LiquidGlassTextCapitalization.none,
      submitAction: LiquidGlassSubmitAction.search,
    ),
    this.style,
    this.controlStyle,
    this.semanticLabel,
  }) : isSearch = true,
       obscureText = false,
       assert(controller == null || initialValue == null);

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? placeholder;
  final bool obscureText;
  final bool enabled;
  final bool isSearch;
  final LiquidGlassTextInputConfiguration configuration;
  final LiquidGlassStyle? style;
  final LiquidGlassControlStyle? controlStyle;
  final String? semanticLabel;

  @override
  State<LiquidGlassTextField> createState() => _LiquidGlassTextFieldState();
}

class _LiquidGlassTextFieldState extends State<LiquidGlassTextField>
    with GlassPlatformViewMixin<LiquidGlassTextField> {
  late TextEditingController _controller;
  late bool _ownsController;
  bool _applyingNativeText = false;

  @override
  String get glassViewType => _kTextFieldViewType;

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller, fallbackText: widget.initialValue ?? '');
  }

  void _bindController(
    TextEditingController? controller, {
    required String fallbackText,
  }) {
    _ownsController = controller == null;
    _controller = controller ?? TextEditingController(text: fallbackText);
    _controller.addListener(_controllerChanged);
  }

  void _controllerChanged() {
    if (!_applyingNativeText) syncConfig();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    final String previousText = _controller.text;
    _controller.removeListener(_controllerChanged);
    if (_ownsController) _controller.dispose();
    _bindController(
      widget.controller,
      fallbackText: widget.initialValue ?? previousText,
    );
  }

  @override
  Map<String, Object?> buildParams() {
    final LiquidGlassStyle glass = resolveGlassStyle(context, widget.style);
    final LiquidGlassControlStyle control = resolveControlStyle(
      context,
      widget.controlStyle,
    );
    return <String, Object?>{
      'text': _controller.text,
      'placeholder': widget.placeholder,
      'obscureText': widget.obscureText,
      'enabled': widget.enabled,
      'isSearch': widget.isSearch,
      'keyboardType': widget.configuration.keyboardType.name,
      'capitalization': widget.configuration.capitalization.name,
      'submitAction': widget.configuration.submitAction.name,
      'autocorrect': widget.configuration.autocorrect,
      'accessibilityLabel': widget.semanticLabel,
      ...encodeStyles(glass, control),
    };
  }

  @override
  Future<Object?> handleCall(MethodCall call) async {
    if (call.method == 'onChanged' && call.arguments is String) {
      final String text = call.arguments as String;
      dispatchControlledNativeState(<String, Object?>{'text': text}, () {
        if (_controller.text != text) {
          _applyingNativeText = true;
          _controller.value = reconcileNativeTextEditingValue(
            _controller.value,
            text,
          );
          _applyingNativeText = false;
        }
        widget.onChanged?.call(text);
      });
    } else if (call.method == 'onSubmitted' && call.arguments is String) {
      widget.onSubmitted?.call(call.arguments as String);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final LiquidGlassStyle glass = resolveGlassStyle(context, widget.style);
    final LiquidGlassControlStyle control = resolveControlStyle(
      context,
      widget.controlStyle,
    );
    if (!isGlassPlatform) {
      return applyFallbackControlStyle(
        controlStyle: control,
        enabled: widget.enabled,
        child: Semantics(
          label: widget.semanticLabel,
          textField: true,
          child: TextField(
            controller: _controller,
            enabled: widget.enabled,
            obscureText: widget.obscureText,
            autocorrect: widget.configuration.autocorrect,
            enableSuggestions: widget.configuration.autocorrect,
            keyboardType: _flutterKeyboardType(
              widget.configuration.keyboardType,
            ),
            textCapitalization: _flutterCapitalization(
              widget.configuration.capitalization,
            ),
            textInputAction: _flutterSubmitAction(
              widget.configuration.submitAction,
            ),
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            style: TextStyle(color: control.foregroundColor),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              prefixIcon: widget.isSearch ? const Icon(Icons.search) : null,
              filled: glass.tint != null,
              fillColor: glass.tint?.withValues(
                alpha: glass.variant == LiquidGlassVariant.clear ? 0.08 : 0.18,
              ),
              border: OutlineInputBorder(
                borderRadius: fallbackBorderRadius(glass.shape),
              ),
            ),
          ),
        ),
      );
    }
    return glassView(
      width: double.infinity,
      height: control.size.minimumDimension,
      gesture: GlassGesture.eager,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }
}

TextInputType _flutterKeyboardType(LiquidGlassKeyboardType type) {
  return switch (type) {
    LiquidGlassKeyboardType.text => TextInputType.text,
    LiquidGlassKeyboardType.emailAddress => TextInputType.emailAddress,
    LiquidGlassKeyboardType.number => TextInputType.number,
    LiquidGlassKeyboardType.decimal => const TextInputType.numberWithOptions(
      decimal: true,
    ),
    LiquidGlassKeyboardType.phone => TextInputType.phone,
    LiquidGlassKeyboardType.url => TextInputType.url,
  };
}

TextCapitalization _flutterCapitalization(
  LiquidGlassTextCapitalization capitalization,
) {
  return switch (capitalization) {
    LiquidGlassTextCapitalization.none => TextCapitalization.none,
    LiquidGlassTextCapitalization.words => TextCapitalization.words,
    LiquidGlassTextCapitalization.sentences => TextCapitalization.sentences,
    LiquidGlassTextCapitalization.characters => TextCapitalization.characters,
  };
}

TextInputAction _flutterSubmitAction(LiquidGlassSubmitAction action) {
  return switch (action) {
    LiquidGlassSubmitAction.done => TextInputAction.done,
    LiquidGlassSubmitAction.go => TextInputAction.go,
    LiquidGlassSubmitAction.next => TextInputAction.next,
    LiquidGlassSubmitAction.search => TextInputAction.search,
    LiquidGlassSubmitAction.send => TextInputAction.send,
  };
}
