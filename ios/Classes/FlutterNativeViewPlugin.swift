import Flutter
import UIKit

public class FlutterNativeViewPlugin: NSObject, FlutterPlugin {
  static let activityIndicatorViewType = "flutter_native_view/glass_activity_indicator"
  static let buttonGroupViewType = "flutter_native_view/glass_button_group"
  static let buttonViewType = "flutter_native_view/glass_button"
  static let checkboxViewType = "flutter_native_view/glass_checkbox"
  static let colorPickerViewType = "flutter_native_view/glass_color_picker"
  static let containerViewType = "flutter_native_view/glass_container"
  static let datePickerViewType = "flutter_native_view/glass_date_picker"
  static let iconButtonViewType = "flutter_native_view/glass_icon_button"
  static let menuViewType = "flutter_native_view/glass_menu"
  static let navigationBarViewType = "flutter_native_view/glass_navigation_bar"
  static let progressViewType = "flutter_native_view/glass_progress"
  static let searchBarViewType = "flutter_native_view/glass_search_bar"
  static let segmentedViewType = "flutter_native_view/glass_segmented"
  static let sliderViewType = "flutter_native_view/glass_slider"
  static let stepperViewType = "flutter_native_view/glass_stepper"
  static let tabBarViewType = "flutter_native_view/glass_tab_bar"
  static let textFieldViewType = "flutter_native_view/glass_text_field"
  static let toggleViewType = "flutter_native_view/glass_toggle"
  static let toolbarViewType = "flutter_native_view/glass_toolbar"

  /// Strong reference so the presenter (and its method-channel handler) is not
  /// deallocated after `register` returns. Without this, the channel handler's
  /// `[weak self]` resolves to nil and every present call silently no-ops.
  private static var presenter: GlassPresenter?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    presenter = GlassPresenter(messenger: messenger, viewController: registrar.viewController)
    registrar.register(
      GlassActivityIndicatorViewFactory(messenger: messenger), withId: activityIndicatorViewType)
    registrar.register(
      GlassButtonGroupViewFactory(messenger: messenger), withId: buttonGroupViewType)
    registrar.register(
      GlassButtonViewFactory(messenger: messenger), withId: buttonViewType)
    registrar.register(
      GlassCheckboxViewFactory(messenger: messenger), withId: checkboxViewType)
    registrar.register(
      GlassColorPickerViewFactory(messenger: messenger), withId: colorPickerViewType)
    registrar.register(
      GlassContainerViewFactory(messenger: messenger), withId: containerViewType)
    registrar.register(
      GlassDatePickerViewFactory(messenger: messenger), withId: datePickerViewType)
    registrar.register(
      GlassIconButtonViewFactory(messenger: messenger), withId: iconButtonViewType)
    registrar.register(
      GlassMenuViewFactory(messenger: messenger), withId: menuViewType)
    registrar.register(
      GlassNavigationBarViewFactory(messenger: messenger), withId: navigationBarViewType)
    registrar.register(
      GlassProgressViewFactory(messenger: messenger), withId: progressViewType)
    registrar.register(
      GlassSearchBarViewFactory(messenger: messenger), withId: searchBarViewType)
    registrar.register(
      GlassSegmentedViewFactory(messenger: messenger), withId: segmentedViewType)
    registrar.register(
      GlassSliderViewFactory(messenger: messenger), withId: sliderViewType)
    registrar.register(
      GlassStepperViewFactory(messenger: messenger), withId: stepperViewType)
    registrar.register(
      GlassTabBarViewFactory(messenger: messenger, hostViewController: registrar.viewController),
      withId: tabBarViewType)
    registrar.register(
      GlassTextFieldViewFactory(messenger: messenger), withId: textFieldViewType)
    registrar.register(
      GlassToggleViewFactory(messenger: messenger), withId: toggleViewType)
    registrar.register(
      GlassToolbarViewFactory(messenger: messenger), withId: toolbarViewType)
  }
}
