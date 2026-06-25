import SwiftUI

/// Helpers for honoring the system accessibility settings on native Liquid
/// Glass. Each glass view passes its `respectAccessibility` flag (forwarded
/// from `LiquidGlassTheme`) plus the relevant SwiftUI `@Environment` value.
enum GlassAccessibility {
  /// Whether interactive glass should respond to touch. Suppressed when the
  /// user has enabled *Reduce Motion*.
  static func interactive(_ requested: Bool, respect: Bool, reduceMotion: Bool) -> Bool {
    respect ? (requested && !reduceMotion) : requested
  }

  /// Whether to drop the translucent glass material for an opaque fill, used
  /// when the user has enabled *Reduce Transparency*.
  static func solidFallback(respect: Bool, reduceTransparency: Bool) -> Bool {
    respect && reduceTransparency
  }
}
