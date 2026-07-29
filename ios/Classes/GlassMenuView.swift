import Flutter
import SwiftUI
import UIKit

private struct GlassMenuItem: Identifiable {
  let id: Int
  let label: String
  let symbol: String?
  let enabled: Bool
}

private struct GlassMenuConfiguration {
  let label: String
  let symbol: String?
  let enabled: Bool
  let accessibilityLabel: String?
  let items: [GlassMenuItem]
  let style: GlassStyleConfiguration
  let controlStyle: GlassControlStyleConfiguration

  init(arguments: GlassArguments) {
    label = arguments.string("label", default: "Menu")
    symbol = arguments.string("symbol")
    enabled = arguments.bool("enabled", default: true)
    accessibilityLabel = arguments.string("accessibilityLabel")
    items = arguments.items("items").enumerated().map { index, item in
      GlassMenuItem(
        id: index,
        label: item.string("label", default: ""),
        symbol: item.string("symbol"),
        enabled: item.bool("enabled", default: true))
    }
    style = GlassStyleConfiguration(arguments: arguments)
    controlStyle = GlassControlStyleConfiguration(arguments: arguments)
  }
}

private final class GlassMenuModel: ObservableObject {
  @Published var configuration: GlassMenuConfiguration
  var onSelected: ((Int) -> Void)?

  init(arguments: GlassArguments) {
    configuration = GlassMenuConfiguration(arguments: arguments)
  }

  func apply(_ arguments: GlassArguments) {
    configuration = GlassMenuConfiguration(arguments: arguments)
  }
}

@available(iOS 15.0, *)
private struct GlassMenuRoot: View {
  @ObservedObject var model: GlassMenuModel

  private var trigger: some View {
    HStack(spacing: 7) {
      if let symbol = model.configuration.symbol { Image(systemName: symbol) }
      Text(model.configuration.label)
    }
    .font(.system(size: 17, weight: .semibold))
    .padding(.horizontal, 16)
    .frame(minHeight: minimumHeight)
    .modifier(
      GlassEffectModifier(
        style: model.configuration.style,
        solidFallbackColor: .secondarySystemBackground))
  }

  var body: some View {
    Menu {
      ForEach(model.configuration.items) { item in
        Button(action: { model.onSelected?(item.id) }) {
          if let symbol = item.symbol {
            Label(item.label, systemImage: symbol)
          } else {
            Text(item.label)
          }
        }
        .disabled(!item.enabled)
      }
    } label: {
      trigger
    }
    .buttonStyle(.plain)
    .modifier(GlassControlStyleModifier(style: model.configuration.controlStyle))
    .disabled(!model.configuration.enabled)
    .opacity(
      model.configuration.enabled ? 1 : model.configuration.controlStyle.disabledOpacity)
    .accessibilityLabel(
      model.configuration.accessibilityLabel.map(Text.init)
        ?? Text(model.configuration.label))
  }

  private var minimumHeight: CGFloat {
    switch model.configuration.controlStyle.size {
    case .compact: return 36
    case .regular: return 44
    case .large: return 52
    }
  }
}

enum GlassMenuView {
  static func make(
    frame: CGRect,
    viewId: Int64,
    arguments: GlassArguments,
    messenger: FlutterBinaryMessenger
  ) -> FlutterPlatformView {
    let model = GlassMenuModel(arguments: arguments)
    let host = GlassPlatformViewHost(
      frame: frame,
      viewType: FlutterNativeViewPlugin.menuViewType,
      viewId: viewId,
      messenger: messenger,
      rootView: AnyView(GlassMenuRoot(model: model)),
      fallbackSize: CGSize(width: 120, height: 44),
      onUpdate: { [weak model] next in
        model?.apply(next)
        return true
      })
    host.applyInterfaceStyle(arguments)
    model.onSelected = { [weak host] index in host?.emit("onSelected", arguments: index) }
    return host
  }
}
