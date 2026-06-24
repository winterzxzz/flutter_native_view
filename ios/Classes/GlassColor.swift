import UIKit

/// Decodes a Flutter ARGB32 integer into a `UIColor`.
enum GlassColor {
  static func fromARGB(_ argb: Int?) -> UIColor? {
    guard let argb = argb else { return nil }
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }
}
