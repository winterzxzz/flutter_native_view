import Flutter
import SwiftUI
import UIKit

private struct GlassTextFieldConfiguration {
  var text: String
  let placeholder: String
  let obscureText: Bool
  let enabled: Bool
  let isSearch: Bool
  let keyboardType: String
  let capitalization: String
  let submitAction: String
  let autocorrect: Bool
  let accessibilityLabel: String?
  let style: GlassStyleConfiguration
  let controlStyle: GlassControlStyleConfiguration

  init(arguments: GlassArguments) {
    text = arguments.string("text", default: "")
    placeholder = arguments.string("placeholder", default: "")
    obscureText = arguments.bool("obscureText")
    enabled = arguments.bool("enabled", default: true)
    isSearch = arguments.bool("isSearch")
    keyboardType = arguments.string("keyboardType", default: "text")
    capitalization = arguments.string("capitalization", default: "sentences")
    submitAction = arguments.string("submitAction", default: "done")
    autocorrect = arguments.bool("autocorrect", default: true)
    accessibilityLabel = arguments.string("accessibilityLabel")
    style = GlassStyleConfiguration(arguments: arguments)
    controlStyle = GlassControlStyleConfiguration(arguments: arguments)
  }

  var keyboard: UIKeyboardType {
    switch keyboardType {
    case "emailAddress": return .emailAddress
    case "number": return .numberPad
    case "decimal": return .decimalPad
    case "phone": return .phonePad
    case "url": return .URL
    default: return .default
    }
  }

  var textCapitalization: TextInputAutocapitalization {
    switch capitalization {
    case "none": return .never
    case "words": return .words
    case "characters": return .characters
    default: return .sentences
    }
  }

  var submitLabel: SubmitLabel {
    switch submitAction {
    case "go": return .go
    case "next": return .next
    case "search": return .search
    case "send": return .send
    default: return .done
    }
  }
}

private final class GlassTextFieldModel: ObservableObject {
  @Published var configuration: GlassTextFieldConfiguration
  var onChanged: ((String) -> Void)?
  var onSubmitted: ((String) -> Void)?

  init(arguments: GlassArguments) {
    configuration = GlassTextFieldConfiguration(arguments: arguments)
  }

  func apply(_ arguments: GlassArguments) {
    configuration = GlassTextFieldConfiguration(arguments: arguments)
  }

  func setTextFromUser(_ text: String) {
    configuration.text = text
    onChanged?(text)
  }
}

@available(iOS 15.0, *)
private struct GlassTextFieldRoot: View {
  @ObservedObject var model: GlassTextFieldModel

  private var text: Binding<String> {
    Binding(
      get: { model.configuration.text },
      set: model.setTextFromUser)
  }

  @ViewBuilder
  private var field: some View {
    if model.configuration.obscureText {
      SecureField(model.configuration.placeholder, text: text)
    } else {
      TextField(model.configuration.placeholder, text: text)
    }
  }

  var body: some View {
    HStack(spacing: 8) {
      if model.configuration.isSearch {
        Image(systemName: "magnifyingglass")
          .accessibilityHidden(true)
      }
      field
        .keyboardType(model.configuration.keyboard)
        .textInputAutocapitalization(model.configuration.textCapitalization)
        .submitLabel(model.configuration.submitLabel)
        .disableAutocorrection(!model.configuration.autocorrect)
        .onSubmit { model.onSubmitted?(model.configuration.text) }
    }
    .padding(.horizontal, 14)
    .frame(minHeight: minimumHeight)
    .modifier(
      GlassEffectModifier(
        style: model.configuration.style,
        solidFallbackColor: .secondarySystemBackground))
    .modifier(GlassControlStyleModifier(style: model.configuration.controlStyle))
    .disabled(!model.configuration.enabled)
    .opacity(
      model.configuration.enabled ? 1 : model.configuration.controlStyle.disabledOpacity)
    .accessibilityLabel(
      model.configuration.accessibilityLabel.map(Text.init)
        ?? Text(model.configuration.placeholder))
  }

  private var minimumHeight: CGFloat {
    switch model.configuration.controlStyle.size {
    case .compact: return 36
    case .regular: return 44
    case .large: return 52
    }
  }
}

enum GlassTextFieldView {
  static func make(
    frame: CGRect,
    viewId: Int64,
    arguments: GlassArguments,
    messenger: FlutterBinaryMessenger
  ) -> FlutterPlatformView {
    let model = GlassTextFieldModel(arguments: arguments)
    let host = GlassPlatformViewHost(
      frame: frame,
      viewType: FlutterNativeViewPlugin.textFieldViewType,
      viewId: viewId,
      messenger: messenger,
      rootView: AnyView(GlassTextFieldRoot(model: model)),
      fallbackSize: CGSize(width: 240, height: 44),
      onUpdate: { [weak model] next in
        model?.apply(next)
        return false
      })
    host.applyInterfaceStyle(arguments)
    model.onChanged = { [weak host] text in host?.emit("onChanged", arguments: text) }
    model.onSubmitted = { [weak host] text in host?.emit("onSubmitted", arguments: text) }
    return host
  }
}
