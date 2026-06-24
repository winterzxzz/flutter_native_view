import Flutter
import UIKit

public class FlutterNativeViewPlugin: NSObject, FlutterPlugin {
  static let buttonViewType = "flutter_native_view/glass_button"
  static let toggleViewType = "flutter_native_view/glass_toggle"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    registrar.register(
      GlassButtonViewFactory(messenger: messenger), withId: buttonViewType)
    registrar.register(
      GlassToggleViewFactory(messenger: messenger), withId: toggleViewType)
  }
}
