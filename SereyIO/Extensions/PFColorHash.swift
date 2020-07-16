//
//  PFColorHash.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/8/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

extension Color {
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

open class PFColorHash {
    
    lazy var lightness: [Double] = [0.5, 0.5, 0.65]
    
    lazy var saturation: [Double] = [0.5, 0.5, 0.65]

    // MARK: Init Methods
    init() {}
    
    init(lightness: [Double]) {
        self.lightness = lightness
    }
    
    init(saturation: [Double]) {
        self.saturation = saturation
    }
    
    init(lightness: [Double], saturation: [Double]) {
        self.lightness = lightness
        self.saturation = saturation
    }
    
    fileprivate func hash(_ str: String) -> Int64 {
        let seed1: Int64 = 131
        let seed2: Int64 = 137
        let hashString = str + "x"
        let constantInt: Int64 = 9007199254740991   // pow(2, 53) - 1
        let maxSafeInt: Int64 = constantInt / seed2
        
        return self.generateRet(hashString: hashString, maxSafeInt: maxSafeInt, seed1: seed1, seed2: seed2)
    }
    
    fileprivate func generateRet(hashString: String, maxSafeInt: Int64, seed1: Int64, seed2: Int64) -> Int64 {
        var ret: Int64 = 0
        
        for element in hashString {
            if (ret > maxSafeInt) {
                ret = ret / seed2
            }
            
            ret = ret * seed1 + Int64(element.unicodeScalarCodePoint())
        }
        
        return ret
    }
    
    // MARK: Public Methods
    final func hsl(_ str: String) -> (h: Double, s: Double, l: Double) {
        var hashValue: Int64 = hash(str)
        let h = hashValue % 359
        
        hashValue = hashValue / 360
        var count: Int64 = Int64(saturation.count)
        var index = Int(hashValue % count)
        let s = saturation[index]
        
        hashValue = hashValue / count
        count = Int64(lightness.count)
        index = Int(hashValue % count)
        let l = lightness[index]
        
        return (Double(h), Double(s), Double(l))
    }
    
    
    final func rgb(_ str: String) -> (r: Int, g: Int, b: Int) {
        let hslValue = hsl(str)
        return hsl2rgb(hslValue.h, s: hslValue.s, l: hslValue.l)
    }
    
    final func hex(_ str: String) -> String {
        let rgbValue = rgb(str)
        return rgb2hex(rgbValue.r, g: rgbValue.g, b: rgbValue.b)
    }
    
    // MARK: Private Methods
    fileprivate final func hsl2rgb(_ h: Double, s: Double, l:Double) -> (r: Int, g: Int, b: Int) {
        let hue = h / 360
        let q = l < 0.5 ? l * (1 + s) :l + s - l * s
        let p = 2 * l - q
        let array = [hue + 1/3, hue, hue - 1/3].map({ (color: Double) -> Int in
            var ret = color
            if (ret < 0) {
                ret = ret + 1
            }
            if (ret > 1) {
                ret = ret - 1
            }
            if (ret < 1 / 6) {
                ret = p + (q - p) * 6 * ret
            } else if (ret < 0.5) {
                ret = q
            } else if (ret < 2 / 3) {
                ret = p + (q - p) * 6 * (2 / 3 - ret)
            } else {
                ret = p
            }
            return Int(ret * 255)
            }
        )
        return (array[0], array[1], array[2])
    }
    
    fileprivate final func rgb2hex(_ r: Int, g: Int, b: Int) -> String {
        return String(format:"%X", r) + String(format:"%X", g) + String(format:"%X", b)
    }
}

// MARK: Character To ASCII
extension Character {
    
    func unicodeScalarCodePoint() -> Int {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return Int(scalars[scalars.startIndex].value)
    }
}
