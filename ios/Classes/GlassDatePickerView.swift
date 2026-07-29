import Flutter
import SwiftUI
import UIKit

private struct GlassDatePickerConfiguration {
  var value: Date
  let minimumDate: Date
  let maximumDate: Date
  let components: String
  let enabled: Bool
  let accessibilityLabel: String?
  let controlStyle: GlassControlStyleConfiguration

  init(arguments: GlassArguments) {
    let minimumMilliseconds = arguments.double("minimumDate")
    let maximumMilliseconds = arguments.double("maximumDate")
    minimumDate = minimumMilliseconds
      .map { Date(timeIntervalSince1970: $0 / 1_000) } ?? .distantPast
    maximumDate = maximumMilliseconds
      .map { Date(timeIntervalSince1970: $0 / 1_000) } ?? .distantFuture
    let milliseconds = arguments.double("value", default: 0)
    value = min(
      max(Date(timeIntervalSince1970: milliseconds / 1_000), minimumDate),
      maximumDate)
    components = arguments.string("components", default: "date")
    enabled = arguments.bool("enabled", default: true)
    accessibilityLabel = arguments.string("accessibilityLabel")
    controlStyle = GlassControlStyleConfiguration(arguments: arguments)
  }

  var displayedComponents: DatePickerComponents {
    switch components {
    case "time": return .hourAndMinute
    case "dateAndTime": return [.date, .hourAndMinute]
    default: return .date
    }
  }
}

private final class GlassDatePickerModel: ObservableObject {
  @Published var configuration: GlassDatePickerConfiguration
  var onChanged: ((Int64) -> Void)?

  init(arguments: GlassArguments) {
    configuration = GlassDatePickerConfiguration(arguments: arguments)
  }

  func apply(_ arguments: GlassArguments) {
    configuration = GlassDatePickerConfiguration(arguments: arguments)
  }

  func setDate(_ date: Date) {
    configuration.value = date
    onChanged?(Int64((date.timeIntervalSince1970 * 1_000).rounded()))
  }
}

@available(iOS 15.0, *)
private struct GlassDatePickerRoot: View {
  @ObservedObject var model: GlassDatePickerModel

  var body: some View {
    DatePicker(
      "",
      selection: Binding(
        get: { model.configuration.value },
        set: model.setDate),
      in: model.configuration.minimumDate...model.configuration.maximumDate,
      displayedComponents: model.configuration.displayedComponents)
      .datePickerStyle(.compact)
      .labelsHidden()
      .tint(model.configuration.controlStyle.tintColor.map { Color(uiColor: $0) })
      .modifier(GlassControlStyleModifier(style: model.configuration.controlStyle))
      .disabled(!model.configuration.enabled)
      .opacity(
        model.configuration.enabled ? 1 : model.configuration.controlStyle.disabledOpacity)
      .accessibilityLabel(
        model.configuration.accessibilityLabel.map(Text.init) ?? Text("Date"))
  }
}

enum GlassDatePickerView {
  static func make(
    frame: CGRect,
    viewId: Int64,
    arguments: GlassArguments,
    messenger: FlutterBinaryMessenger
  ) -> FlutterPlatformView {
    let model = GlassDatePickerModel(arguments: arguments)
    let host = GlassPlatformViewHost(
      frame: frame,
      viewType: FlutterNativeViewPlugin.datePickerViewType,
      viewId: viewId,
      messenger: messenger,
      rootView: AnyView(GlassDatePickerRoot(model: model)),
      fallbackSize: CGSize(width: 190, height: 44),
      onUpdate: { [weak model] next in
        model?.apply(next)
        return true
      })
    host.applyInterfaceStyle(arguments)
    model.onChanged = { [weak host] value in host?.emit("onChanged", arguments: value) }
    return host
  }
}
