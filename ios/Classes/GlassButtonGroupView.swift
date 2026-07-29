import Flutter
import SwiftUI
import UIKit

private struct GlassButtonGroupItem: Identifiable {
  let id: String
  let label: String?
  let symbol: String?
  let enabled: Bool
  let accessibilityLabel: String?
  let style: GlassStyleConfiguration
  let controlStyle: GlassControlStyleConfiguration

  init(arguments: GlassArguments) {
    id = arguments.string("id", default: "")
    label = arguments.string("label")
    symbol = arguments.string("symbol")
    enabled = arguments.bool("enabled", default: true)
    accessibilityLabel = arguments.string("accessibilityLabel")
    style = GlassStyleConfiguration(arguments: arguments)
    controlStyle = GlassControlStyleConfiguration(arguments: arguments)
  }
}

private struct GlassButtonGroupConfiguration {
  let items: [GlassButtonGroupItem]
  let spacing: CGFloat

  init(arguments: GlassArguments) {
    items = arguments.items("items").map(GlassButtonGroupItem.init)
    spacing = CGFloat(max(0, min(arguments.double("spacing", default: 8), 1_000)))
  }
}

private final class GlassButtonGroupModel: ObservableObject {
  @Published var configuration: GlassButtonGroupConfiguration
  var onPressed: ((String) -> Void)?

  init(arguments: GlassArguments) {
    configuration = GlassButtonGroupConfiguration(arguments: arguments)
  }

  func apply(_ arguments: GlassArguments) {
    configuration = GlassButtonGroupConfiguration(arguments: arguments)
  }
}

@available(iOS 15.0, *)
private struct GlassButtonGroupRoot: View {
  @ObservedObject var model: GlassButtonGroupModel
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  @ViewBuilder
  private func label(for item: GlassButtonGroupItem) -> some View {
    HStack(spacing: 6) {
      if let symbol = item.symbol { Image(systemName: symbol) }
      if let label = item.label { Text(label) }
    }
    .font(.system(size: 16, weight: .semibold))
    .padding(.horizontal, 16)
    .frame(minHeight: item.controlStyle.size == .compact ? 36 : item.controlStyle.size == .large ? 52 : 44)
  }

  @ViewBuilder
  private func button(for item: GlassButtonGroupItem) -> some View {
    let button = Button(action: { model.onPressed?(item.id) }) {
      label(for: item)
    }
    .modifier(GlassButtonShapeModifier(shape: item.style.shape))
    .modifier(GlassControlStyleModifier(style: item.controlStyle))
    .tint(item.style.tint.map { Color(uiColor: $0) })
    .disabled(!item.enabled)
    .opacity(item.enabled ? 1 : item.controlStyle.disabledOpacity)
    .accessibilityLabel(
      item.accessibilityLabel.map(Text.init) ?? Text(item.label ?? "Button"))

    if #available(iOS 26.0, *) {
      button.buttonStyle(.glass(item.style.glass(reduceMotion: reduceMotion)))
    } else {
      button.buttonStyle(.bordered)
    }
  }

  @ViewBuilder
  var body: some View {
    if #available(iOS 26.0, *) {
      GlassEffectContainer(spacing: model.configuration.spacing) {
        HStack(spacing: model.configuration.spacing) {
          ForEach(model.configuration.items) { item in button(for: item) }
        }
      }
    } else {
      HStack(spacing: model.configuration.spacing) {
        ForEach(model.configuration.items) { item in button(for: item) }
      }
    }
  }
}

enum GlassButtonGroupView {
  static func make(
    frame: CGRect,
    viewId: Int64,
    arguments: GlassArguments,
    messenger: FlutterBinaryMessenger
  ) -> FlutterPlatformView {
    let model = GlassButtonGroupModel(arguments: arguments)
    let host = GlassPlatformViewHost(
      frame: frame,
      viewType: FlutterNativeViewPlugin.buttonGroupViewType,
      viewId: viewId,
      messenger: messenger,
      rootView: AnyView(GlassButtonGroupRoot(model: model)),
      fallbackSize: CGSize(width: 220, height: 44),
      onUpdate: { [weak model] next in
        model?.apply(next)
        return true
      })
    host.applyInterfaceStyle(arguments)
    model.onPressed = { [weak host] id in host?.emit("onPressed", arguments: id) }
    return host
  }
}
