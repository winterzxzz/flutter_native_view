import Flutter
import UIKit

// MARK: - Factory

final class GlassTabBarViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger
  private weak var hostViewController: UIViewController?

  init(messenger: FlutterBinaryMessenger, hostViewController: UIViewController?) {
    self.messenger = messenger
    self.hostViewController = hostViewController
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
    -> FlutterPlatformView
  {
    GlassTabBarPlatformView(
      frame: frame, viewId: viewId,
      args: args as? [String: Any] ?? [:],
      messenger: messenger,
      hostViewController: hostViewController)
  }
}

// MARK: - Config

/// Strongly-typed tab bar configuration parsed from Flutter creation params.
struct GlassTabBarConfig {
  struct Tab {
    let label: String
    let sfSymbol: String
    let badge: String?
  }

  let tabs: [Tab]
  let currentIndex: Int
  let selectedColor: UIColor?
  let accessorySymbol: String?

  init(args: [String: Any]) {
    tabs = (args["items"] as? [[String: Any]] ?? []).map {
      Tab(
        label: $0["label"] as? String ?? "",
        sfSymbol: $0["sfSymbol"] as? String ?? "circle",
        badge: $0["badge"] as? String)
    }
    let requested = args["currentIndex"] as? Int ?? 0
    currentIndex = min(max(0, requested), max(tabs.count - 1, 0))
    selectedColor = GlassColor.fromARGB(args["tint"] as? Int)
    accessorySymbol = args["accessorySymbol"] as? String
  }
}

// MARK: - Native tab bar host

/// Hosts a real `UITabBarController` so the OS draws the authentic Liquid Glass
/// tab bar (floating glass, minimize-on-scroll, search accessory) on iOS 26+.
///
/// Each tab is an empty `UIViewController` — Flutter renders the actual screen
/// content. We only borrow the system tab bar chrome. The optional trailing
/// accessory is a `.search`-tagged item intercepted in `shouldSelect` so it
/// fires a callback instead of switching tabs.
final class GlassNativeTabBarView: UIView, UITabBarControllerDelegate {
  private static let accessoryTag = 9999

  let tabBarController = UITabBarController()
  private let config: GlassTabBarConfig
  private let onIndexChanged: (Int) -> Void
  private let onAccessoryTap: () -> Void
  private var selectableCount: Int { config.tabs.count }

  /// Drives the native minimize-on-scroll. Flutter content can't be observed by
  /// UIKit directly, so we register this hidden scroll view as the selected
  /// tab's content scroll view and mirror Flutter's scroll offset onto it —
  /// UIKit watches its `contentOffset` to minimize/expand the bar.
  private let proxyScroll = UIScrollView()

  init(
    config: GlassTabBarConfig,
    onIndexChanged: @escaping (Int) -> Void,
    onAccessoryTap: @escaping () -> Void
  ) {
    self.config = config
    self.onIndexChanged = onIndexChanged
    self.onAccessoryTap = onAccessoryTap
    super.init(frame: .zero)

    backgroundColor = .clear
    clipsToBounds = false
    configure()
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

  private func configure() {
    var controllers: [UIViewController] = config.tabs.map { tab in
      let vc = UIViewController()
      vc.view.backgroundColor = .clear
      vc.tabBarItem = UITabBarItem(
        title: tab.label,
        image: UIImage(systemName: tab.sfSymbol),
        selectedImage: UIImage(systemName: tab.sfSymbol))
      vc.tabBarItem.badgeValue = tab.badge
      return vc
    }

    if let accessory = config.accessorySymbol {
      let vc = UIViewController()
      vc.view.backgroundColor = .clear
      let item = UITabBarItem(tabBarSystemItem: .search, tag: Self.accessoryTag)
      item.image = UIImage(systemName: accessory)
      item.selectedImage = UIImage(systemName: accessory)
      vc.tabBarItem = item
      controllers.append(vc)
    }

    tabBarController.delegate = self
    tabBarController.view.backgroundColor = .clear
    tabBarController.view.clipsToBounds = false
    tabBarController.setViewControllers(controllers, animated: false)
    tabBarController.selectedIndex = config.currentIndex

    if #available(iOS 18.0, *) {
      tabBarController.mode = .tabBar
    }
    if #available(iOS 26.0, *) {
      tabBarController.tabBarMinimizeBehavior = .onScrollDown
    }

    let tabBar = tabBarController.tabBar
    tabBar.clipsToBounds = false
    applySelectedColor()
    configureProxyScroll()
    embed()
  }

  /// Registers the hidden proxy scroll view as the selected tab's content
  /// scroll view so `tabBarMinimizeBehavior` has something to track.
  private func configureProxyScroll() {
    proxyScroll.isUserInteractionEnabled = false
    proxyScroll.showsVerticalScrollIndicator = false
    proxyScroll.contentInsetAdjustmentBehavior = .never
    proxyScroll.backgroundColor = .clear
    proxyScroll.alpha = 0.0
    proxyScroll.translatesAutoresizingMaskIntoConstraints = false
    proxyScroll.contentSize = CGSize(width: 1, height: 100_000)
    attachProxyToSelectedTab()
  }

  private func attachProxyToSelectedTab() {
    guard let vc = tabBarController.selectedViewController else { return }
    proxyScroll.removeFromSuperview()
    vc.view.addSubview(proxyScroll)
    NSLayoutConstraint.activate([
      proxyScroll.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
      proxyScroll.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
      proxyScroll.topAnchor.constraint(equalTo: vc.view.topAnchor),
      proxyScroll.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
    ])
    if #available(iOS 18.0, *) {
      vc.setContentScrollView(proxyScroll, for: .bottom)
    }
  }

  /// Mirror Flutter's scroll position. UIKit reads the resulting `contentOffset`
  /// change (and its direction) to drive `.onScrollDown` minimize/expand.
  func applyScrollOffset(_ pixels: CGFloat) {
    let maxY = max(0, proxyScroll.contentSize.height - proxyScroll.bounds.height)
    let clamped = max(0, min(pixels, maxY))
    guard abs(proxyScroll.contentOffset.y - clamped) > 0.5 else { return }
    proxyScroll.contentOffset = CGPoint(x: 0, y: clamped)
  }

  private func embed() {
    guard let controllerView = tabBarController.view else { return }
    controllerView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(controllerView)
    NSLayoutConstraint.activate([
      controllerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      controllerView.trailingAnchor.constraint(equalTo: trailingAnchor),
      controllerView.topAnchor.constraint(equalTo: topAnchor),
      controllerView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  /// Proper UIKit parent-child containment — required for an embedded controller.
  func attach(to parent: UIViewController?) {
    guard let parent, tabBarController.parent !== parent else { return }
    if tabBarController.parent != nil {
      tabBarController.willMove(toParent: nil)
      tabBarController.removeFromParent()
    }
    parent.addChild(tabBarController)
    tabBarController.didMove(toParent: parent)
    applySelectedColor()
  }

  deinit {
    if tabBarController.parent != nil {
      tabBarController.willMove(toParent: nil)
      tabBarController.removeFromParent()
    }
  }

  /// Re-assert tint after Flutter navigation push/pop reattaches the view, which
  /// otherwise lets UIKit re-resolve the selected color back to system blue.
  override func didMoveToWindow() {
    super.didMoveToWindow()
    guard window != nil else { return }
    applySelectedColor()
  }

  private func applySelectedColor() {
    guard let color = config.selectedColor else { return }
    let tabBar = tabBarController.tabBar
    tabBar.tintColor = color

    let appearance = tabBar.standardAppearance.copy() as? UITabBarAppearance ?? UITabBarAppearance()
    for item in [
      appearance.stackedLayoutAppearance,
      appearance.inlineLayoutAppearance,
      appearance.compactInlineLayoutAppearance,
    ] {
      item.selected.iconColor = color
      var attrs = item.selected.titleTextAttributes
      attrs[.foregroundColor] = color
      item.selected.titleTextAttributes = attrs
    }
    tabBar.standardAppearance = appearance
    if #available(iOS 15.0, *) {
      tabBar.scrollEdgeAppearance = appearance
    }
  }

  func setSelectedIndex(_ index: Int) {
    guard selectableCount > 0 else { return }
    let clamped = min(max(0, index), selectableCount - 1)
    guard tabBarController.selectedIndex != clamped else { return }
    tabBarController.selectedIndex = clamped
    applySelectedColor()
  }

  // MARK: UITabBarControllerDelegate

  func tabBarController(
    _ tabBarController: UITabBarController, shouldSelect viewController: UIViewController
  ) -> Bool {
    if viewController.tabBarItem.tag == Self.accessoryTag {
      onAccessoryTap()
      return false
    }
    return true
  }

  func tabBarController(
    _ tabBarController: UITabBarController, didSelect viewController: UIViewController
  ) {
    guard let vcs = tabBarController.viewControllers,
      let index = vcs.firstIndex(where: { $0 === viewController }),
      index < selectableCount
    else { return }
    applySelectedColor()
    attachProxyToSelectedTab()
    onIndexChanged(index)
  }
}

// MARK: - Platform view bridge

final class GlassTabBarPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private weak var hostViewController: UIViewController?
  private var barView: GlassNativeTabBarView?

  init(
    frame: CGRect, viewId: Int64, args: [String: Any],
    messenger: FlutterBinaryMessenger, hostViewController: UIViewController?
  ) {
    self.hostViewController = hostViewController
    channel = FlutterMethodChannel(
      name: "\(FlutterNativeViewPlugin.tabBarViewType)/\(viewId)", binaryMessenger: messenger)
    container.backgroundColor = .clear
    container.clipsToBounds = false
    super.init()

    let config = GlassTabBarConfig(args: args)
    let bar = GlassNativeTabBarView(
      config: config,
      onIndexChanged: { [weak channel] index in
        channel?.invokeMethod("onIndexChanged", arguments: index)
      },
      onAccessoryTap: { [weak channel] in
        channel?.invokeMethod("onAccessoryTap", arguments: nil)
      })
    bar.translatesAutoresizingMaskIntoConstraints = false
    bar.attach(to: hostViewController)
    container.addSubview(bar)
    NSLayoutConstraint.activate([
      bar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      bar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      bar.topAnchor.constraint(equalTo: container.topAnchor),
      bar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])
    barView = bar

    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "updateConfig":
        if let index = (call.arguments as? [String: Any])?["currentIndex"] as? Int {
          self?.barView?.setSelectedIndex(index)
        }
        result(nil)
      case "setScrollOffset":
        if let pixels = (call.arguments as? NSNumber)?.doubleValue {
          self?.barView?.applyScrollOffset(CGFloat(pixels))
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { container }
}
