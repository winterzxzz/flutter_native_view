import Flutter
import SwiftUI
import UIKit

// MARK: - Parse-first channel boundary

/// Typed access to unknown values received from FlutterStandardMessageCodec.
struct GlassArguments {
  let raw: [String: Any]

  init(_ value: Any?) {
    raw = value as? [String: Any] ?? [:]
  }

  func nested(_ key: String) -> GlassArguments {
    GlassArguments(raw[key])
  }

  func string(_ key: String) -> String? {
    raw[key] as? String
  }

  func string(_ key: String, default fallback: String) -> String {
    string(key) ?? fallback
  }

  func bool(_ key: String, default fallback: Bool = false) -> Bool {
    (raw[key] as? NSNumber)?.boolValue ?? raw[key] as? Bool ?? fallback
  }

  func double(_ key: String) -> Double? {
    if let number = raw[key] as? NSNumber { return number.doubleValue }
    return raw[key] as? Double
  }

  func double(_ key: String, default fallback: Double) -> Double {
    double(key) ?? fallback
  }

  func int(_ key: String) -> Int? {
    if let number = raw[key] as? NSNumber { return number.intValue }
    return raw[key] as? Int
  }

  func int(_ key: String, default fallback: Int) -> Int {
    int(key) ?? fallback
  }

  func items(_ key: String) -> [GlassArguments] {
    guard let values = raw[key] as? [Any] else { return [] }
    return values.map(GlassArguments.init)
  }
}

// MARK: - Shared style configuration

enum GlassMaterialVariant {
  case regular
  case clear
}

enum GlassShapeConfiguration {
  case capsule
  case circle
  case roundedRectangle(radius: CGFloat)

  init(arguments: GlassArguments) {
    switch arguments.string("kind") {
    case "circle":
      self = .circle
    case "roundedRectangle":
      let radius = max(0, min(arguments.double("cornerRadius", default: 16), 1_000))
      self = .roundedRectangle(radius: CGFloat(radius))
    default:
      self = .capsule
    }
  }
}

struct GlassStyleConfiguration {
  let variant: GlassMaterialVariant
  let tint: UIColor?
  let shape: GlassShapeConfiguration
  let interactive: Bool

  init(arguments: GlassArguments) {
    let style = arguments.nested("style")
    variant = style.string("variant") == "clear" ? .clear : .regular
    tint = GlassColor.fromARGB(style.int("tint"))
    shape = GlassShapeConfiguration(arguments: style.nested("shape"))
    interactive = style.bool("interactive", default: true)
  }

  @available(iOS 26.0, *)
  func glass(reduceMotion: Bool) -> Glass {
    var value: Glass = variant == .clear ? .clear : .regular
    if let tint { value = value.tint(Color(uiColor: tint)) }
    if interactive && !reduceMotion { value = value.interactive() }
    return value
  }
}

enum GlassControlSizeConfiguration {
  case compact
  case regular
  case large

  var swiftUIValue: ControlSize {
    switch self {
    case .compact: return .small
    case .regular: return .regular
    case .large: return .large
    }
  }
}

struct GlassControlStyleConfiguration {
  let tintColor: UIColor?
  let foregroundColor: UIColor?
  let brightness: String?
  let size: GlassControlSizeConfiguration
  let disabledOpacity: Double

  init(arguments: GlassArguments) {
    let control = arguments.nested("controlStyle")
    tintColor = GlassColor.fromARGB(control.int("tintColor"))
    foregroundColor = GlassColor.fromARGB(control.int("foregroundColor"))
    brightness = control.string("brightness")
    switch control.string("size") {
    case "compact": size = .compact
    case "large": size = .large
    default: size = .regular
    }
    disabledOpacity = max(0, min(control.double("disabledOpacity", default: 0.45), 1))
  }

  var colorScheme: ColorScheme? {
    switch brightness {
    case "light": return .light
    case "dark": return .dark
    default: return nil
    }
  }

  var interfaceStyle: UIUserInterfaceStyle {
    switch brightness {
    case "light": return .light
    case "dark": return .dark
    default: return .unspecified
    }
  }
}

// MARK: - Shared SwiftUI modifiers

struct GlassButtonShapeModifier: ViewModifier {
  let shape: GlassShapeConfiguration

  @ViewBuilder
  func body(content: Content) -> some View {
    switch shape {
    case .capsule:
      content.buttonBorderShape(.capsule)
    case .circle:
      if #available(iOS 17.0, *) {
        content.buttonBorderShape(.circle)
      } else {
        // A capsule over a square icon button is geometrically circular and
        // keeps the iOS 15-16 fallback on an available system shape.
        content.buttonBorderShape(.capsule)
      }
    case .roundedRectangle(let radius):
      content.buttonBorderShape(.roundedRectangle(radius: radius))
    }
  }
}

struct GlassControlStyleModifier: ViewModifier {
  let style: GlassControlStyleConfiguration

  func body(content: Content) -> some View {
    content
      .controlSize(style.size.swiftUIValue)
      .foregroundStyle(style.foregroundColor.map { Color(uiColor: $0) } ?? .primary)
      .preferredColorScheme(style.colorScheme)
  }
}

/// Applies custom Liquid Glass after all content layout modifiers.
struct GlassEffectModifier: ViewModifier {
  let style: GlassStyleConfiguration
  let solidFallbackColor: UIColor
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

  @ViewBuilder
  func body(content: Content) -> some View {
    if reduceTransparency {
      let opaqueColor = (style.tint ?? solidFallbackColor).withAlphaComponent(1)
      colorBackground(content: content, color: Color(uiColor: opaqueColor))
    } else if #available(iOS 26.0, *) {
      glass(content: content)
    } else {
      materialBackground(content: content)
    }
  }

  @available(iOS 26.0, *)
  @ViewBuilder
  private func glass(content: Content) -> some View {
    switch style.shape {
    case .capsule:
      content.glassEffect(style.glass(reduceMotion: reduceMotion), in: Capsule())
    case .circle:
      content.glassEffect(style.glass(reduceMotion: reduceMotion), in: Circle())
    case .roundedRectangle(let radius):
      content.glassEffect(
        style.glass(reduceMotion: reduceMotion),
        in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
  }

  @ViewBuilder
  private func colorBackground(content: Content, color: Color) -> some View {
    switch style.shape {
    case .capsule:
      content.background(color, in: Capsule())
    case .circle:
      content.background(color, in: Circle())
    case .roundedRectangle(let radius):
      content.background(
        color,
        in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
  }

  @ViewBuilder
  private func materialBackground(content: Content) -> some View {
    switch style.shape {
    case .capsule:
      content.background { materialSurface(Capsule()) }
    case .circle:
      content.background { materialSurface(Circle()) }
    case .roundedRectangle(let radius):
      content.background {
        materialSurface(RoundedRectangle(cornerRadius: radius, style: .continuous))
      }
    }
  }

  private func materialSurface<S: Shape>(_ shape: S) -> some View {
    shape
      .fill(.ultraThinMaterial)
      .overlay {
        if let tint = style.tint {
          shape.fill(Color(uiColor: tint).opacity(0.18))
        }
      }
  }
}

// MARK: - Shared platform-view factory and host

typealias GlassPlatformViewBuilder = (
  CGRect, Int64, GlassArguments, FlutterBinaryMessenger
) -> FlutterPlatformView

final class GlassPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger
  private let builder: GlassPlatformViewBuilder

  init(messenger: FlutterBinaryMessenger, builder: @escaping GlassPlatformViewBuilder) {
    self.messenger = messenger
    self.builder = builder
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    builder(frame, viewId, GlassArguments(args), messenger)
  }
}

/// Owns hosting, channel dispatch, intrinsic measurement, and teardown.
private final class GlassHostingContainerView: UIView {
  var onWindowChanged: ((UIWindow?) -> Void)?

  override func didMoveToWindow() {
    super.didMoveToWindow()
    onWindowChanged?(window)
  }

  var nearestViewController: UIViewController? {
    var responder: UIResponder? = self
    while let current = responder {
      if let viewController = current as? UIViewController { return viewController }
      responder = current.next
    }
    return nil
  }
}

final class GlassPlatformViewHost: NSObject, FlutterPlatformView {
  typealias UpdateHandler = (GlassArguments) -> Bool

  private let container: GlassHostingContainerView
  private let channel: FlutterMethodChannel
  private let hostingController: UIHostingController<AnyView>
  private let updateHandler: UpdateHandler
  private let fallbackSize: CGSize

  init(
    frame: CGRect,
    viewType: String,
    viewId: Int64,
    messenger: FlutterBinaryMessenger,
    rootView: AnyView,
    fallbackSize: CGSize,
    onUpdate: @escaping UpdateHandler
  ) {
    container = GlassHostingContainerView(frame: frame)
    channel = FlutterMethodChannel(
      name: "\(viewType)/\(viewId)", binaryMessenger: messenger)
    hostingController = UIHostingController(rootView: rootView)
    updateHandler = onUpdate
    self.fallbackSize = fallbackSize
    super.init()

    container.backgroundColor = .clear
    container.clipsToBounds = false
    hostingController.view.backgroundColor = .clear
    hostingController.view.frame = container.bounds
    hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    container.addSubview(hostingController.view)
    container.onWindowChanged = { [weak self] window in
      self?.updateContainment(isInWindow: window != nil)
    }

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "disposed", message: "Native view was disposed.", details: nil))
        return
      }
      switch call.method {
      case "getIntrinsicSize":
        result(self.intrinsicSize())
      case "updateConfig":
        let needsMeasurement = self.updateHandler(GlassArguments(call.arguments))
        self.applyInterfaceStyle(GlassArguments(call.arguments))
        if needsMeasurement {
          DispatchQueue.main.async { result(self.intrinsicSize()) }
        } else {
          result(nil)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func emit(_ method: String, arguments: Any? = nil) {
    channel.invokeMethod(method, arguments: arguments)
  }

  func applyInterfaceStyle(_ arguments: GlassArguments) {
    let style = GlassControlStyleConfiguration(arguments: arguments).interfaceStyle
    container.overrideUserInterfaceStyle = style
    hostingController.overrideUserInterfaceStyle = style
  }

  private func intrinsicSize() -> [String: Double] {
    let size: CGSize
    if #available(iOS 16.0, *) {
      size = hostingController.sizeThatFits(
        in: CGSize(width: 10_000, height: 10_000))
    } else {
      hostingController.view.setNeedsLayout()
      hostingController.view.layoutIfNeeded()
      size = hostingController.view.systemLayoutSizeFitting(
        UIView.layoutFittingCompressedSize)
    }
    let width = size.width.isFinite && size.width > 0 ? ceil(size.width) : fallbackSize.width
    let height = size.height.isFinite && size.height > 0 ? ceil(size.height) : fallbackSize.height
    return ["width": Double(width), "height": Double(height)]
  }

  func view() -> UIView { container }

  private func updateContainment(isInWindow: Bool) {
    let requestedParent = isInWindow ? container.nearestViewController : nil
    if hostingController.parent === requestedParent { return }
    if hostingController.parent != nil {
      hostingController.willMove(toParent: nil)
      hostingController.removeFromParent()
    }
    if let requestedParent {
      requestedParent.addChild(hostingController)
      hostingController.didMove(toParent: requestedParent)
    }
  }

  deinit {
    channel.setMethodCallHandler(nil)
    container.onWindowChanged = nil
    updateContainment(isInWindow: false)
    hostingController.view.removeFromSuperview()
  }
}
