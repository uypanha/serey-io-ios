// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSColor
  internal typealias Color = NSColor
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIColor
  internal typealias Color = UIColor
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Colors

// swiftlint:disable identifier_name line_length type_body_length
internal struct ColorName {
  internal let rgbaValue: UInt32
  internal var color: Color { return Color(named: self) }

  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ff5b5b"></span>
  /// Alpha: 100% <br/> (0xff5b5bff)
  internal static let almostRed = ColorName(rgbaValue: 0xff5b5bff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
  /// Alpha: 100% <br/> (0xffffffff)
  internal static let navigationBg = ColorName(rgbaValue: 0xffffffff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#0c0c0c"></span>
  /// Alpha: 100% <br/> (0x0c0c0cff)
  internal static let navigationTint = ColorName(rgbaValue: 0x0c0c0cff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#4ecd77"></span>
  /// Alpha: 100% <br/> (0x4ecd77ff)
  internal static let positive = ColorName(rgbaValue: 0x4ecd77ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#657fde"></span>
  /// Alpha: 100% <br/> (0x657fdeff)
  internal static let primary = ColorName(rgbaValue: 0x657fdeff)
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

// swiftlint:disable operator_usage_whitespace
internal extension Color {
  convenience init(rgbaValue: UInt32) {
    let red   = CGFloat((rgbaValue >> 24) & 0xff) / 255.0
    let green = CGFloat((rgbaValue >> 16) & 0xff) / 255.0
    let blue  = CGFloat((rgbaValue >>  8) & 0xff) / 255.0
    let alpha = CGFloat((rgbaValue      ) & 0xff) / 255.0

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
// swiftlint:enable operator_usage_whitespace

internal extension Color {
  convenience init(named color: ColorName) {
    self.init(rgbaValue: color.rgbaValue)
  }
}
