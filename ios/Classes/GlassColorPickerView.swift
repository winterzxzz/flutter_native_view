import Flutter
import SwiftUI
import UIKit

private struct GlassColorPickerConfiguration {
  var value: UIColor
  let supportsOpacity: Bool
  let enabled: Bool
  let accessibilityLabel: String?
  let controlStyle: GlassControlStyleConfiguration

  init(arguments: GlassArguments) {
    value = GlassColor.fromARGB(arguments.int("value")) ?? .systemBlue
    supportsOpacity = arguments.bool("supportsOpacity", default: true)
    enabled = arguments.bool("enabled", default: true)
    accessibilityLabel = arguments.string("accessibilityLabel")
    controlStyle = GlassControlStyleConfiguration(arguments: arguments)
  }
}

private final class GlassColorPickerModel: ObservableObject {
  @Published var configuration: GlassColorPickerConfiguration
  var onChanged: ((Int) -> Void)?

  init(arguments: GlassArguments) {
    configuration = GlassColorPickerConfiguration(arguments: arguments)
  }

  func apply(_ arguments: GlassArguments) {
    configuration = GlassColorPickerConfiguration(arguments: arguments)
  }

  func setColor(_ color: Color) {
    let value = UIColor(color)
    configuration.value = value
    onChanged?(GlassColor.toARGB(value))
  }
}

@available(iOS 15.0, *)
private struct GlassColorPickerRoot: View {
  @ObservedObject var model: GlassColorPickerModel

  var body: some View {
    ColorPicker(
      "",
      selection: Binding(
        get: { Color(uiColor: model.configuration.value) },
        set: model.setColor),
      supportsOpacity: model.configuration.supportsOpacity)
      .labelsHidden()
      .modifier(GlassControlStyleModifier(style: model.configuration.controlStyle))
      .disabled(!model.configuration.enabled)
      .opacity(
        model.configuration.enabled ? 1 : model.configuration.controlStyle.disabledOpacity)
      .accessibilityLabel(
        model.configuration.accessibilityLabel.map(Text.init) ?? Text("Color"))
  }
}

enum GlassColorPickerView {
  static func make(
    frame: CGRect,
    viewId: Int64,
    arguments: GlassArguments,
    messenger: FlutterBinaryMessenger
  ) -> FlutterPlatformView {
    let model = GlassColorPickerModel(arguments: arguments)
    let host = GlassPlatformViewHost(
      frame: frame,
      viewType: FlutterNativeViewPlugin.colorPickerViewType,
      viewId: viewId,
      messenger: messenger,
      rootView: AnyView(GlassColorPickerRoot(model: model)),
      fallbackSize: CGSize(width: 60, height: 44),
      onUpdate: { [weak model] next in
        model?.apply(next)
        return true
      })
    host.applyInterfaceStyle(arguments)
    model.onChanged = { [weak host] value in host?.emit("onChanged", arguments: value) }
    return host
  }
}
