import Flutter
import SwiftUI
import UIKit

private struct GlassToggleConfiguration {
  var value: Bool
  let enabled: Bool
  let accessibilityLabel: String?
  let controlStyle: GlassControlStyleConfiguration

  init(arguments: GlassArguments) {
    value = arguments.bool("value")
    enabled = arguments.bool("enabled", default: true)
    accessibilityLabel = arguments.string("accessibilityLabel")
    controlStyle = GlassControlStyleConfiguration(arguments: arguments)
  }
}

private final class GlassToggleModel: ObservableObject {
  @Published var configuration: GlassToggleConfiguration
  var onChanged: ((Bool) -> Void)?

  init(arguments: GlassArguments) {
    configuration = GlassToggleConfiguration(arguments: arguments)
  }

  func apply(_ arguments: GlassArguments) {
    configuration = GlassToggleConfiguration(arguments: arguments)
  }

  func setValue(_ value: Bool) {
    configuration.value = value
    onChanged?(value)
  }
}

@available(iOS 15.0, *)
private struct GlassToggleRoot: View {
  @ObservedObject var model: GlassToggleModel

  var body: some View {
    Toggle(
      "",
      isOn: Binding(
        get: { model.configuration.value },
        set: model.setValue))
      .labelsHidden()
      .tint(model.configuration.controlStyle.tintColor.map { Color(uiColor: $0) })
      .modifier(GlassControlStyleModifier(style: model.configuration.controlStyle))
      .disabled(!model.configuration.enabled)
      .opacity(
        model.configuration.enabled ? 1 : model.configuration.controlStyle.disabledOpacity)
      .accessibilityLabel(
        model.configuration.accessibilityLabel.map(Text.init) ?? Text("Toggle"))
  }
}

enum GlassToggleView {
  static func make(
    frame: CGRect,
    viewId: Int64,
    arguments: GlassArguments,
    messenger: FlutterBinaryMessenger
  ) -> FlutterPlatformView {
    let model = GlassToggleModel(arguments: arguments)
    let host = GlassPlatformViewHost(
      frame: frame,
      viewType: FlutterNativeViewPlugin.toggleViewType,
      viewId: viewId,
      messenger: messenger,
      rootView: AnyView(GlassToggleRoot(model: model)),
      fallbackSize: CGSize(width: 52, height: 32),
      onUpdate: { [weak model] next in
        model?.apply(next)
        return true
      })
    host.applyInterfaceStyle(arguments)
    model.onChanged = { [weak host] value in host?.emit("onChanged", arguments: value) }
    return host
  }
}
