import Flutter
import SwiftUI
import UIKit

private struct GlassButtonConfiguration {
  let label: String?
  let iconOnlySymbol: String?
  let leadingSymbol: String?
  let trailingSymbol: String?
  let prominent: Bool
  let enabled: Bool
  let accessibilityLabel: String?
  let style: GlassStyleConfiguration
  let controlStyle: GlassControlStyleConfiguration

  init(arguments: GlassArguments) {
    label = arguments.string("label")
    iconOnlySymbol = arguments.string("iconOnlySymbol")
    leadingSymbol = arguments.string("leadingSymbol")
    trailingSymbol = arguments.string("trailingSymbol")
    prominent = arguments.string("prominence") == "prominent"
    enabled = arguments.bool("enabled", default: true)
    accessibilityLabel = arguments.string("accessibilityLabel")
    style = GlassStyleConfiguration(arguments: arguments)
    controlStyle = GlassControlStyleConfiguration(arguments: arguments)
  }
}

private final class GlassButtonModel: ObservableObject {
  @Published var configuration: GlassButtonConfiguration
  var onPressed: (() -> Void)?

  init(arguments: GlassArguments) {
    configuration = GlassButtonConfiguration(arguments: arguments)
  }

  func apply(_ arguments: GlassArguments) {
    configuration = GlassButtonConfiguration(arguments: arguments)
  }
}

@available(iOS 15.0, *)
private struct GlassButtonRoot: View {
  @ObservedObject var model: GlassButtonModel
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private var configuration: GlassButtonConfiguration { model.configuration }

  private var dimension: CGFloat {
    switch configuration.controlStyle.size {
    case .compact: return 36
    case .regular: return 44
    case .large: return 52
    }
  }

  @ViewBuilder
  private var label: some View {
    if let symbol = configuration.iconOnlySymbol {
      Image(systemName: symbol)
        .font(.system(size: dimension * 0.43, weight: .semibold))
        .frame(width: dimension, height: dimension)
    } else {
      HStack(spacing: 7) {
        if let symbol = configuration.leadingSymbol {
          Image(systemName: symbol)
        }
        if let label = configuration.label {
          Text(label)
        }
        if let symbol = configuration.trailingSymbol {
          Image(systemName: symbol)
        }
      }
      .font(.system(size: dimension * 0.38, weight: .semibold))
      .padding(.horizontal, dimension * 0.42)
      .frame(minHeight: dimension)
    }
  }

  private var button: some View {
    Button(action: { model.onPressed?() }) { label }
      .modifier(GlassButtonShapeModifier(shape: configuration.style.shape))
      .modifier(GlassControlStyleModifier(style: configuration.controlStyle))
      .tint(configuration.style.tint.map { Color(uiColor: $0) })
      .disabled(!configuration.enabled)
      .opacity(configuration.enabled ? 1 : configuration.controlStyle.disabledOpacity)
      .accessibilityLabel(
        configuration.accessibilityLabel
          .map(Text.init) ?? Text(configuration.label ?? "Button"))
  }

  @ViewBuilder
  var body: some View {
    if #available(iOS 26.0, *) {
      if configuration.prominent {
        button.buttonStyle(.glassProminent)
      } else {
        button.buttonStyle(.glass(configuration.style.glass(reduceMotion: reduceMotion)))
      }
    } else if configuration.prominent {
      button.buttonStyle(.borderedProminent)
    } else {
      button.buttonStyle(.bordered)
    }
  }
}

enum GlassButtonView {
  static func make(
    frame: CGRect,
    viewId: Int64,
    arguments: GlassArguments,
    messenger: FlutterBinaryMessenger
  ) -> FlutterPlatformView {
    let model = GlassButtonModel(arguments: arguments)
    let host = GlassPlatformViewHost(
      frame: frame,
      viewType: FlutterNativeViewPlugin.buttonViewType,
      viewId: viewId,
      messenger: messenger,
      rootView: AnyView(GlassButtonRoot(model: model)),
      fallbackSize: CGSize(width: 120, height: 44),
      onUpdate: { [weak model] next in
        model?.apply(next)
        return true
      })
    host.applyInterfaceStyle(arguments)
    model.onPressed = { [weak host] in host?.emit("onPressed") }
    return host
  }
}
