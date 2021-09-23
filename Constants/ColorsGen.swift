// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSColor
  internal typealias Color = NSColor
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIColor
  internal typealias Color = UIColor
#endif

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Colors

// swiftlint:disable identifier_name line_length type_body_length
internal struct ColorName {
  internal let rgbaValue: UInt32
  internal var color: Color { return Color(named: self) }

  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ff5b5b"></span>
  /// Alpha: 100% <br/> (0xff5b5bff)
  internal static let almostRed = ColorName(rgbaValue: 0xff5b5bff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#dbdbdb"></span>
  /// Alpha: 100% <br/> (0xdbdbdbff)
  internal static let border = ColorName(rgbaValue: 0xdbdbdbff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#7f98ed"></span>
  /// Alpha: 100% <br/> (0x7f98edff)
  internal static let buttonBg = ColorName(rgbaValue: 0x7f98edff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#cccccc"></span>
  /// Alpha: 100% <br/> (0xccccccff)
  internal static let disabled = ColorName(rgbaValue: 0xccccccff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#eff2fc"></span>
  /// Alpha: 100% <br/> (0xeff2fcff)
  internal static let lightPrimary = ColorName(rgbaValue: 0xeff2fcff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
  /// Alpha: 100% <br/> (0xffffffff)
  internal static let navigationBg = ColorName(rgbaValue: 0xffffffff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#414141"></span>
  /// Alpha: 100% <br/> (0x414141ff)
  internal static let navigationTint = ColorName(rgbaValue: 0x414141ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#4ecd77"></span>
  /// Alpha: 100% <br/> (0x4ecd77ff)
  internal static let positive = ColorName(rgbaValue: 0x4ecd77ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
  /// Alpha: 100% <br/> (0xffffffff)
  internal static let postBackground = ColorName(rgbaValue: 0xffffffff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#3f5ac4"></span>
  /// Alpha: 100% <br/> (0x3f5ac4ff)
  internal static let primary = ColorName(rgbaValue: 0x3f5ac4ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#d30020"></span>
  /// Alpha: 100% <br/> (0xd30020ff)
  internal static let primaryRed = ColorName(rgbaValue: 0xd30020ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#1e358f"></span>
  /// Alpha: 100% <br/> (0x1e358fff)
  internal static let secondary = ColorName(rgbaValue: 0x1e358fff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#e8e8e8"></span>
  /// Alpha: 100% <br/> (0xe8e8e8ff)
  internal static let shimmering = ColorName(rgbaValue: 0xe8e8e8ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
  /// Alpha: 100% <br/> (0xffffffff)
  internal static let tabBarBg = ColorName(rgbaValue: 0xffffffff)
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

internal extension Color {
  convenience init(rgbaValue: UInt32) {
    let components = RGBAComponents(rgbaValue: rgbaValue).normalized
    self.init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
  }
}

private struct RGBAComponents {
  let rgbaValue: UInt32

  private var shifts: [UInt32] {
    [
      rgbaValue >> 24, // red
      rgbaValue >> 16, // green
      rgbaValue >> 8,  // blue
      rgbaValue        // alpha
    ]
  }

  private var components: [CGFloat] {
    shifts.map {
      CGFloat($0 & 0xff)
    }
  }

  var normalized: [CGFloat] {
    components.map { $0 / 255.0 }
  }
}

internal extension Color {
  convenience init(named color: ColorName) {
    self.init(rgbaValue: color.rgbaValue)
  }
}
