import Flutter
import UIKit

public class FlutterNativeViewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    registrar.register(
      GlassSurfaceViewFactory(messenger: messenger),
      withId: "flutter_native_view/glass_surface")
    registrar.register(
      GlassSwitchViewFactory(messenger: messenger),
      withId: "flutter_native_view/glass_switch")
  }
}
