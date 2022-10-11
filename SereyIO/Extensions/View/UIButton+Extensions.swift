//
//  UIButton+Extensions.swift
//  SereyIO
//
//  Created by Mäd on 03/02/2022.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit

extension UIButton {
    
    static var DEFAULT_BUTTON_HEIGHT: CGFloat {
        return 48
    }
    
    static func createButton(with fontSize: CGFloat = 16, weight: UIFont.Weight = .regular) -> UIButton {
        return .init().then {
            $0.titleLabel?.font = UIFont.customFont(with: fontSize, weight: weight)
            $0.tintColor = .black
            $0.setTitleColor(.black, for: .normal)
        }
    }
}
