//
//  UIColor+Extensions.swift
//  SereyIO
//
//  Created by Panha Uy on 9/28/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func color(_ colorName: ColorName) -> UIColor {
        return colorName.color
    }
    
    static func color(_ hexString: String) -> UIColor {
        var colorHex = hexString
        if colorHex.hasPrefix("#") {
            let start = colorHex.index(colorHex.startIndex, offsetBy: 1)
            colorHex = String(colorHex[start...])
        }
        return UIColor(hexString: colorHex)
    }
}
