//
//  UILabel+Helper.swift
//  SereyIO
//
//  Created by Panha Uy on 9/28/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import Then

extension UILabel {
    
    static func createLabel(_ textSize: CGFloat, weight: UIFont.Weight = .regular, textColor: UIColor = .black) -> UILabel {
        return .init().then {
            $0.font = .customFont(with: textSize, weight: weight)
            $0.textColor = textColor
        }
    }
}
