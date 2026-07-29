import 'package:flutter/widgets.dart';

/// Maps existing Flutter selection/composing ranges through a native text edit.
///
/// SwiftUI 15 does not expose authoritative selection or marked-text ranges.
/// Mapping the text delta preserves ranges outside the edit and advances a
/// caret through common insert/delete operations instead of collapsing every
/// native edit to the end of the field.
TextEditingValue reconcileNativeTextEditingValue(
  TextEditingValue previous,
  String text,
) {
  if (previous.text == text) return previous;

  final String oldText = previous.text;
  var prefix = 0;
  while (prefix < oldText.length &&
      prefix < text.length &&
      oldText.codeUnitAt(prefix) == text.codeUnitAt(prefix)) {
    prefix++;
  }

  var suffix = 0;
  while (suffix < oldText.length - prefix &&
      suffix < text.length - prefix &&
      oldText.codeUnitAt(oldText.length - suffix - 1) ==
          text.codeUnitAt(text.length - suffix - 1)) {
    suffix++;
  }

  final int oldEditEnd = oldText.length - suffix;
  final int newEditEnd = text.length - suffix;

  int mapOffset(int offset) {
    if (offset < 0) return offset;
    if (offset < prefix) return offset;
    if (offset > oldEditEnd) {
      return (offset + text.length - oldText.length)
          .clamp(0, text.length)
          .toInt();
    }
    return newEditEnd;
  }

  final TextSelection selection = previous.selection.isValid
      ? TextSelection(
          baseOffset: mapOffset(previous.selection.baseOffset),
          extentOffset: mapOffset(previous.selection.extentOffset),
          affinity: previous.selection.affinity,
          isDirectional: previous.selection.isDirectional,
        )
      : previous.selection;

  final TextRange composing = previous.composing.isValid
      ? TextRange(
          start: mapOffset(previous.composing.start),
          end: mapOffset(previous.composing.end),
        )
      : TextRange.empty;

  return TextEditingValue(
    text: text,
    selection: selection,
    composing: composing,
  );
}
