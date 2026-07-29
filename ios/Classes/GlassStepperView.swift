import Flutter
import SwiftUI
import UIKit

private struct GlassStepperConfiguration {
  var value: Int
  let step: Int
  let minimum: Int
  let maximum: Int
  let enabled: Bool
  let accessibilityLabel: String?
  let controlStyle: GlassControlStyleConfiguration

  init(arguments: GlassArguments) {
    let requestedMinimum = arguments.int("min") ?? Int.min / 2
    let requestedMaximum = arguments.int("max") ?? Int.max / 2
    minimum = min(requestedMinimum, requestedMaximum)
    maximum = max(requestedMinimum, requestedMaximum)
    value = max(minimum, min(arguments.int("value", default: 0), maximum))
    step = max(1, arguments.int("step", default: 1))
    enabled = arguments.bool("enabled", default: true)
    accessibilityLabel = arguments.string("accessibilityLabel")
    controlStyle = GlassControlStyleConfiguration(arguments: arguments)
  }
}

private final class GlassStepperModel: ObservableObject {
  @Published var configuration: GlassStepperConfiguration
  var onChanged: ((Int) -> Void)?

  init(arguments: GlassArguments) {
    configuration = GlassStepperConfiguration(arguments: arguments)
  }

  func apply(_ arguments: GlassArguments) {
    configuration = GlassStepperConfiguration(arguments: arguments)
  }

  func setValue(_ value: Int) {
    configuration.value = value
    onChanged?(value)
  }
}

@available(iOS 15.0, *)
private struct GlassStepperRoot: View {
  @ObservedObject var model: GlassStepperModel

  var body: some View {
    Stepper(
      value: Binding(
        get: { model.configuration.value },
        set: model.setValue),
      in: model.configuration.minimum...model.configuration.maximum,
      step: model.configuration.step
    ) {
      Text("\(model.configuration.value)")
        .font(.system(.body, design: .rounded).weight(.semibold))
    }
    .tint(model.configuration.controlStyle.tintColor.map { Color(uiColor: $0) })
    .modifier(GlassControlStyleModifier(style: model.configuration.controlStyle))
    .disabled(!model.configuration.enabled)
    .opacity(
      model.configuration.enabled ? 1 : model.configuration.controlStyle.disabledOpacity)
    .accessibilityLabel(
      model.configuration.accessibilityLabel.map(Text.init) ?? Text("Stepper"))
  }
}

enum GlassStepperView {
  static func make(
    frame: CGRect,
    viewId: Int64,
    arguments: GlassArguments,
    messenger: FlutterBinaryMessenger
  ) -> FlutterPlatformView {
    let model = GlassStepperModel(arguments: arguments)
    let host = GlassPlatformViewHost(
      frame: frame,
      viewType: FlutterNativeViewPlugin.stepperViewType,
      viewId: viewId,
      messenger: messenger,
      rootView: AnyView(GlassStepperRoot(model: model)),
      fallbackSize: CGSize(width: 150, height: 44),
      onUpdate: { [weak model] next in
        model?.apply(next)
        return true
      })
    host.applyInterfaceStyle(arguments)
    model.onChanged = { [weak host] value in host?.emit("onChanged", arguments: value) }
    return host
  }
}
