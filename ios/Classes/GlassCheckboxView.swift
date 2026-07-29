import Flutter
import SwiftUI
import UIKit

private struct GlassCheckboxConfiguration {
  var value: Bool
  let enabled: Bool
  let accessibilityLabel: String?
  let style: GlassStyleConfiguration
  let controlStyle: GlassControlStyleConfiguration

  init(arguments: GlassArguments) {
    value = arguments.bool("value")
    enabled = arguments.bool("enabled", default: true)
    accessibilityLabel = arguments.string("accessibilityLabel")
    style = GlassStyleConfiguration(arguments: arguments)
    controlStyle = GlassControlStyleConfiguration(arguments: arguments)
  }
}

private final class GlassCheckboxModel: ObservableObject {
  @Published var configuration: GlassCheckboxConfiguration
  var onChanged: ((Bool) -> Void)?

  init(arguments: GlassArguments) {
    configuration = GlassCheckboxConfiguration(arguments: arguments)
  }

  func apply(_ arguments: GlassArguments) {
    configuration = GlassCheckboxConfiguration(arguments: arguments)
  }

  func toggle() {
    guard configuration.enabled else { return }
    configuration.value.toggle()
    onChanged?(configuration.value)
  }
}

@available(iOS 15.0, *)
private struct GlassCheckboxRoot: View {
  @ObservedObject var model: GlassCheckboxModel

  private var dimension: CGFloat {
    switch model.configuration.controlStyle.size {
    case .compact: return 24
    case .regular: return 28
    case .large: return 34
    }
  }

  private var hitDimension: CGFloat {
    switch model.configuration.controlStyle.size {
    case .compact: return 36
    case .regular: return 44
    case .large: return 52
    }
  }

  var body: some View {
    Button(action: model.toggle) {
      ZStack {
        RoundedRectangle(cornerRadius: dimension * 0.22, style: .continuous)
          .stroke(.primary.opacity(0.18), lineWidth: 1)
        if model.configuration.value {
          Image(systemName: "checkmark")
            .font(.system(size: dimension * 0.5, weight: .bold))
        }
      }
      .frame(width: dimension, height: dimension)
      .modifier(
        GlassEffectModifier(
          style: model.configuration.style,
          solidFallbackColor: .secondarySystemBackground))
    }
    .buttonStyle(.plain)
    .frame(minWidth: hitDimension, minHeight: hitDimension)
    .contentShape(Rectangle())
    .modifier(GlassControlStyleModifier(style: model.configuration.controlStyle))
    .disabled(!model.configuration.enabled)
    .opacity(
      model.configuration.enabled ? 1 : model.configuration.controlStyle.disabledOpacity)
    .accessibilityLabel(
      model.configuration.accessibilityLabel.map(Text.init) ?? Text("Checkbox"))
    .accessibilityValue(model.configuration.value ? Text("On") : Text("Off"))
  }
}

enum GlassCheckboxView {
  static func make(
    frame: CGRect,
    viewId: Int64,
    arguments: GlassArguments,
    messenger: FlutterBinaryMessenger
  ) -> FlutterPlatformView {
    let model = GlassCheckboxModel(arguments: arguments)
    let host = GlassPlatformViewHost(
      frame: frame,
      viewType: FlutterNativeViewPlugin.checkboxViewType,
      viewId: viewId,
      messenger: messenger,
      rootView: AnyView(GlassCheckboxRoot(model: model)),
      fallbackSize: CGSize(width: 28, height: 28),
      onUpdate: { [weak model] next in
        model?.apply(next)
        return false
      })
    host.applyInterfaceStyle(arguments)
    model.onChanged = { [weak host] value in host?.emit("onChanged", arguments: value) }
    return host
  }
}
