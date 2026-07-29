import UIKit

enum GlassColor {
  static func fromARGB(_ argb: Int?) -> UIColor? {
    guard let argb else { return nil }
    return UIColor(
      red: CGFloat((argb >> 16) & 0xFF) / 255,
      green: CGFloat((argb >> 8) & 0xFF) / 255,
      blue: CGFloat(argb & 0xFF) / 255,
      alpha: CGFloat((argb >> 24) & 0xFF) / 255)
  }

  static func toARGB(_ color: UIColor) -> Int {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
      return 0xFF000000
    }
    return (Int((alpha * 255).rounded()) << 24)
      | (Int((red * 255).rounded()) << 16)
      | (Int((green * 255).rounded()) << 8)
      | Int((blue * 255).rounded())
  }
}
