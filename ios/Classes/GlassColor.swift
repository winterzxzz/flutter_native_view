import SwiftUI

/// Decodes a Flutter ARGB32 integer into a SwiftUI `Color`.
enum GlassColor {
  static func fromARGB(_ argb: Int?) -> Color? {
    guard let argb = argb else { return nil }
    let a = Double((argb >> 24) & 0xFF) / 255.0
    let r = Double((argb >> 16) & 0xFF) / 255.0
    let g = Double((argb >> 8) & 0xFF) / 255.0
    let b = Double(argb & 0xFF) / 255.0
    return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
  }
}
