import Flutter
import UIKit

public final class FlutterNativeViewPlugin: NSObject, FlutterPlugin {
  static let buttonViewType = "liquid_glass_native/button"
  static let buttonGroupViewType = "liquid_glass_native/button_group"
  static let checkboxViewType = "liquid_glass_native/checkbox"
  static let colorPickerViewType = "liquid_glass_native/color_picker"
  static let datePickerViewType = "liquid_glass_native/date_picker"
  static let menuViewType = "liquid_glass_native/menu"
  static let segmentedViewType = "liquid_glass_native/segmented"
  static let sliderViewType = "liquid_glass_native/slider"
  static let stepperViewType = "liquid_glass_native/stepper"
  static let textFieldViewType = "liquid_glass_native/text_field"
  static let toggleViewType = "liquid_glass_native/toggle"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    registrar.register(
      GlassPlatformViewFactory(messenger: messenger, builder: GlassButtonView.make),
      withId: buttonViewType)
    registrar.register(
      GlassPlatformViewFactory(messenger: messenger, builder: GlassButtonGroupView.make),
      withId: buttonGroupViewType)
    registrar.register(
      GlassPlatformViewFactory(messenger: messenger, builder: GlassCheckboxView.make),
      withId: checkboxViewType)
    registrar.register(
      GlassPlatformViewFactory(messenger: messenger, builder: GlassColorPickerView.make),
      withId: colorPickerViewType)
    registrar.register(
      GlassPlatformViewFactory(messenger: messenger, builder: GlassDatePickerView.make),
      withId: datePickerViewType)
    registrar.register(
      GlassPlatformViewFactory(messenger: messenger, builder: GlassMenuView.make),
      withId: menuViewType)
    registrar.register(
      GlassPlatformViewFactory(messenger: messenger, builder: GlassSegmentedView.make),
      withId: segmentedViewType)
    registrar.register(
      GlassPlatformViewFactory(messenger: messenger, builder: GlassSliderView.make),
      withId: sliderViewType)
    registrar.register(
      GlassPlatformViewFactory(messenger: messenger, builder: GlassStepperView.make),
      withId: stepperViewType)
    registrar.register(
      GlassPlatformViewFactory(messenger: messenger, builder: GlassTextFieldView.make),
      withId: textFieldViewType)
    registrar.register(
      GlassPlatformViewFactory(messenger: messenger, builder: GlassToggleView.make),
      withId: toggleViewType)
  }
}
