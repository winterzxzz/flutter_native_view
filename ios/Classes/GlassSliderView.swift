import Flutter
import SwiftUI
import UIKit

private struct GlassSliderConfiguration {
  var value: Double
  let minimum: Double
  let maximum: Double
  let enabled: Bool
  let accessibilityLabel: String?
  let controlStyle: GlassControlStyleConfiguration

  init(arguments: GlassArguments) {
    let lower = arguments.double("min", default: 0)
    let upper = max(lower + Double.ulpOfOne, arguments.double("max", default: 1))
    minimum = lower
    maximum = upper
    value = max(lower, min(arguments.double("value", default: lower), upper))
    enabled = arguments.bool("enabled", default: true)
    accessibilityLabel = arguments.string("accessibilityLabel")
    controlStyle = GlassControlStyleConfiguration(arguments: arguments)
  }
}

private final class GlassSliderModel: ObservableObject {
  @Published var configuration: GlassSliderConfiguration
  var onChanged: ((Double) -> Void)?

  init(arguments: GlassArguments) {
    configuration = GlassSliderConfiguration(arguments: arguments)
  }

  func apply(_ arguments: GlassArguments) {
    configuration = GlassSliderConfiguration(arguments: arguments)
  }

  func setValue(_ value: Double) {
    configuration.value = value
    onChanged?(value)
  }
}

@available(iOS 15.0, *)
private struct GlassSliderRoot: View {
  @ObservedObject var model: GlassSliderModel

  var body: some View {
    Slider(
      value: Binding(
        get: { model.configuration.value },
        set: model.setValue),
      in: model.configuration.minimum...model.configuration.maximum)
      .tint(model.configuration.controlStyle.tintColor.map { Color(uiColor: $0) })
      .modifier(GlassControlStyleModifier(style: model.configuration.controlStyle))
      .disabled(!model.configuration.enabled)
      .opacity(
        model.configuration.enabled ? 1 : model.configuration.controlStyle.disabledOpacity)
      .accessibilityLabel(
        model.configuration.accessibilityLabel.map(Text.init) ?? Text("Slider"))
  }
}

enum GlassSliderView {
  static func make(
    frame: CGRect,
    viewId: Int64,
    arguments: GlassArguments,
    messenger: FlutterBinaryMessenger
  ) -> FlutterPlatformView {
    let model = GlassSliderModel(arguments: arguments)
    let host = GlassPlatformViewHost(
      frame: frame,
      viewType: FlutterNativeViewPlugin.sliderViewType,
      viewId: viewId,
      messenger: messenger,
      rootView: AnyView(GlassSliderRoot(model: model)),
      fallbackSize: CGSize(width: 200, height: 44),
      onUpdate: { [weak model] next in
        model?.apply(next)
        return false
      })
    host.applyInterfaceStyle(arguments)
    model.onChanged = { [weak host] value in host?.emit("onChanged", arguments: value) }
    return host
  }
}
