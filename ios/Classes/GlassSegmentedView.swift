import Flutter
import SwiftUI
import UIKit

private struct GlassSegmentItem: Identifiable {
  let id: Int
  let label: String
  let symbol: String?
}

private struct GlassSegmentedConfiguration {
  let segments: [GlassSegmentItem]
  var selectedIndex: Int
  let enabled: Bool
  let accessibilityLabel: String?
  let controlStyle: GlassControlStyleConfiguration

  init(arguments: GlassArguments) {
    segments = arguments.items("segments").enumerated().map { index, item in
      GlassSegmentItem(
        id: index,
        label: item.string("label", default: ""),
        symbol: item.string("symbol"))
    }
    selectedIndex = max(
      0,
      min(arguments.int("selectedIndex", default: 0), max(segments.count - 1, 0)))
    enabled = arguments.bool("enabled", default: true)
    accessibilityLabel = arguments.string("accessibilityLabel")
    controlStyle = GlassControlStyleConfiguration(arguments: arguments)
  }
}

private final class GlassSegmentedModel: ObservableObject {
  @Published var configuration: GlassSegmentedConfiguration
  var onChanged: ((Int) -> Void)?

  init(arguments: GlassArguments) {
    configuration = GlassSegmentedConfiguration(arguments: arguments)
  }

  func apply(_ arguments: GlassArguments) {
    configuration = GlassSegmentedConfiguration(arguments: arguments)
  }

  func setIndex(_ index: Int) {
    configuration.selectedIndex = index
    onChanged?(index)
  }
}

@available(iOS 15.0, *)
private struct GlassSegmentedRoot: View {
  @ObservedObject var model: GlassSegmentedModel

  var body: some View {
    Picker(
      "",
      selection: Binding(
        get: { model.configuration.selectedIndex },
        set: model.setIndex)
    ) {
      ForEach(model.configuration.segments) { segment in
        if let symbol = segment.symbol {
          Label(segment.label, systemImage: symbol).tag(segment.id)
        } else {
          Text(segment.label).tag(segment.id)
        }
      }
    }
    .pickerStyle(.segmented)
    .tint(model.configuration.controlStyle.tintColor.map { Color(uiColor: $0) })
    .modifier(GlassControlStyleModifier(style: model.configuration.controlStyle))
    .disabled(!model.configuration.enabled)
    .opacity(
      model.configuration.enabled ? 1 : model.configuration.controlStyle.disabledOpacity)
    .accessibilityLabel(
      model.configuration.accessibilityLabel.map(Text.init) ?? Text("Options"))
  }
}

enum GlassSegmentedView {
  static func make(
    frame: CGRect,
    viewId: Int64,
    arguments: GlassArguments,
    messenger: FlutterBinaryMessenger
  ) -> FlutterPlatformView {
    let model = GlassSegmentedModel(arguments: arguments)
    let host = GlassPlatformViewHost(
      frame: frame,
      viewType: FlutterNativeViewPlugin.segmentedViewType,
      viewId: viewId,
      messenger: messenger,
      rootView: AnyView(GlassSegmentedRoot(model: model)),
      fallbackSize: CGSize(width: 220, height: 44),
      onUpdate: { [weak model] next in
        model?.apply(next)
        return true
      })
    host.applyInterfaceStyle(arguments)
    model.onChanged = { [weak host] index in host?.emit("onChanged", arguments: index) }
    return host
  }
}
