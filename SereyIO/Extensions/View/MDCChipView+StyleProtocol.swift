//
//  MDCChipView+StyleProtocol.swift
//  SereyIO
//
//  Created by Mäd on 13/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents
import Kingfisher
import RxKingfisher

extension MDCChipView: StyleProtocol {
    
    func commonStyle(_ cornerRadius: CGFloat = 8) {
        self.cornerRadius = cornerRadius
        clearShadowColor()
    }
    
    func clearShadowColor() {
        self.setShadowColor(.clear, for: .highlighted)
        self.setShadowColor(.clear, for: .selected)
        self.setShadowColor(.clear, for: .normal)
        self.setShadowColor(.clear, for: .application)
        self.setShadowColor(.clear, for: .reserved)
        self.setShadowColor(.clear, for: .focused)
    }
    
    func primaryStyle() {
        self.commonStyle()
        self.imageView.tintColor = .color(.icon)
        self.selectedImageView.tintColor = .color(.primary)
        self.setTitleColor(.color(.icon), for: .normal)
        self.setTitleColor(.color(.primary), for: .highlighted)
        self.setTitleColor(.color(.primary), for: .selected)
        self.setBorderColor(.color(.border), for: .normal)
        self.setBorderWidth(1, for: .normal)
        self.setBackgroundColor(.white, for: .normal)
        self.setBackgroundColor(.color(.secondaryLight), for: .highlighted)
        self.setBackgroundColor(.color(.secondaryLight), for: .selected)
    }
    
    func secondaryStyle() {
    }
    
    func dangerouseStyle() {
    }
}


extension MDCChipView {
    
    func prepareStyle(with properties: ChipProperties) {
        self.setTitleColor(properties.textColor, for: .normal)
        self.setTitleColor(properties.textColor, for: .selected)
        
        self.setBackgroundColor(properties.backgroundColor, for: .normal)
        self.setBackgroundColor(properties.backgroundColor, for: .selected)
        
        self.setShadowColor(.clear, for: .normal)
        self.setInkColor(.clear, for: .normal)
        self.setBorderColor(properties.borderColor, for: .normal)
        let borderWidth: CGFloat = (properties.borderColor == nil || properties.borderColor == .clear) ? 0 : 1
        self.setBorderWidth(borderWidth, for: .normal)
        
        self.titleLabel.text = properties.text
        self.titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        self.sizeToFit()
    }
}

struct ChipProperties {
    
    var text: String = ""
    var textColor: UIColor = .darkGray
    var borderColor: UIColor? = .clear
    var backgroundColor: UIColor = .lightGray
    
    static func defaultProperties() -> ChipProperties {
        return ChipProperties(text: "", textColor: .darkGray, backgroundColor: .clear)
    }
}
