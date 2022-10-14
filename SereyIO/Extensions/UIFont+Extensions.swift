//
//  UIFont+Extensions.swift
//  SereyIO
//
//  Created by Panha Uy on 9/28/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit

extension UIFont {
    
    static func customFont(with size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        return .systemFont(ofSize: size, weight: weight)
    }
    
//    static func prepareFont(_ name: String, size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
//        return UIFont(name: name, size: size) ?? .systemFont(ofSize: size, weight: weight)
//    }
}

//// MARK: - Khmer Fonts
//fileprivate extension UIFont {
//
//    static func khmerFontName(for weight: UIFont.Weight = .regular) -> String {
//        switch weight {
//        case .regular:
//            return "Kantumruy-Regular"
//        case .medium, .semibold:
//            return "Kantumruy-Regular"
//        case .thin, .light, .ultraLight:
//            return "Kantumruy-Light"
//        case .black, .bold, .heavy:
//            return "Kantumruy-Bold"
//        default:
//            return "Kantumruy-Regular"
//        }
//    }
//
//    static func robotoFontName(for weight: UIFont.Weight = .regular) -> String {
//        switch weight {
//        case .regular:
//            return "Roboto-Regular"
//        case .medium, .semibold:
//            return "Roboto-Medium"
//        case .light:
//            return "Roboto-Light"
//        case .thin, .ultraLight:
//            return "Roboto-Thin"
//        case .black, .bold, .heavy:
//            return "Roboto-Bold"
//        default:
//            return "Roboto-Regular"
//        }
//    }
//}
