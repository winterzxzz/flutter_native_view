import Flutter
import SwiftUI
import UIKit

final class GlassPresenter: NSObject {
  private let channel: FlutterMethodChannel
  private weak var viewController: UIViewController?
  private var activeHost: UIViewController?

  init(messenger: FlutterBinaryMessenger, viewController: UIViewController?) {
    self.viewController = viewController
    channel = FlutterMethodChannel(
      name: "flutter_native_view/presenter", binaryMessenger: messenger)
    super.init()

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "presentSheet":
        self.presentSheet(args: call.arguments as? [String: Any] ?? [:], result: result)
      case "presentAlert":
        self.presentAlert(args: call.arguments as? [String: Any] ?? [:], result: result)
      case "presentPopover":
        self.presentPopover(args: call.arguments as? [String: Any] ?? [:], result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func presentSheet(args: [String: Any], result: @escaping FlutterResult) {
    guard let vc = viewController else { result(nil); return }
    guard #available(iOS 16.0, *) else { result(nil); return }
    let title = args["title"] as? String ?? ""
    let sheetView = GlassSheetRoot(
      title: title,
      onDismiss: { [weak self] in
        self?.activeHost?.dismiss(animated: true)
        self?.activeHost = nil
        result(nil)
      })
    let hosting = UIHostingController(rootView: sheetView)
    hosting.view.backgroundColor = .clear
    hosting.modalPresentationStyle = .pageSheet
    if #available(iOS 15.0, *), let sheet = hosting.sheetPresentationController {
      sheet.detents = [.medium(), .large()]
      sheet.prefersGrabberVisible = true
    }
    activeHost = hosting
    vc.present(hosting, animated: true)
  }

  private func presentAlert(args: [String: Any], result: @escaping FlutterResult) {
    guard let vc = viewController else { result(nil); return }
    let title = args["title"] as? String ?? ""
    let message = args["message"] as? String ?? ""
    let buttons = args["buttons"] as? [[String: Any]] ?? []

    let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
    for button in buttons {
      let label = button["label"] as? String ?? "OK"
      let id = button["id"] as? String ?? "ok"
      let style: UIAlertAction.Style = button["destructive"] as? Bool == true ? .destructive : .default
      alertVC.addAction(UIAlertAction(title: label, style: style) { _ in
        result(id)
      })
    }
    vc.present(alertVC, animated: true)
  }

  private func presentPopover(args: [String: Any], result: @escaping FlutterResult) {
    guard let vc = viewController else { result(nil); return }
    guard #available(iOS 16.0, *) else { result(nil); return }
    let title = args["title"] as? String ?? ""
    let popoverView = GlassPopoverRoot(
      title: title,
      onDismiss: { [weak self] in
        self?.activeHost?.dismiss(animated: true)
        self?.activeHost = nil
        result(nil)
      })
    let hosting = UIHostingController(rootView: popoverView)
    hosting.view.backgroundColor = .clear
    hosting.modalPresentationStyle = .popover
    hosting.popoverPresentationController?.sourceView = vc.view
    hosting.popoverPresentationController?.sourceRect = CGRect(
      x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
    hosting.popoverPresentationController?.permittedArrowDirections = .up
    activeHost = hosting
    vc.present(hosting, animated: true)
  }
}

// MARK: - SwiftUI sheet root

@available(iOS 16.0, *)
struct GlassSheetRoot: View {
  let title: String
  let onDismiss: () -> Void

  var body: some View {
    NavigationStack {
      VStack(spacing: 16) {
        Text(title)
          .font(.title2)
          .padding(.top, 24)
        Text("Sheet presented from native")
          .foregroundColor(.secondary)
        Spacer()
        Button("Dismiss") { onDismiss() }
          .buttonStyle(.borderedProminent)
      }
      .padding()
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { onDismiss() }
        }
      }
    }
  }
}

// MARK: - SwiftUI popover root

@available(iOS 16.0, *)
struct GlassPopoverRoot: View {
  let title: String
  let onDismiss: () -> Void

  var body: some View {
    VStack(spacing: 12) {
      Text(title)
        .font(.headline)
      Text("Popover content")
        .foregroundColor(.secondary)
      Button("Close") { onDismiss() }
        .buttonStyle(.bordered)
    }
    .padding()
    .frame(width: 250)
  }
}
