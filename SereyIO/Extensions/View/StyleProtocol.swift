//
//  StyleProtocol.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

protocol StyleProtocol {
    
    func primaryStyle()
    
    func secondaryStyle()
    
    func dangerouseStyle()
}

// MARK: - Buttons
extension UIButton: StyleProtocol {
    
    private func commonBackgroundStyle() {
        if self.backgroundColor != nil {
            self.makeMeCircular()
            self.setBackgroundColor(UIColor.lightGray, for: .disabled)
            self.setBackgroundColor(UIColor.lightGray.withAlphaComponent(0.5), for: .highlighted)
        }
        
        if let image = self.image(for: .normal) {
            self.setImage(image.image(with: 0.5), for: .highlighted)
        }
    }
    
    func commonTextColorStyle() {
        self.setTitleColor(self.titleColor(for: .normal)?.withAlphaComponent(0.5), for: .highlighted)
    }
    
    func primaryStyle() {
        self.customStyle(with: ColorName.primary.color)
    }
    
    func secondaryStyle() {
        self.secondaryStyle(borderColor: ColorName.primary.color, borderWidth: 2)
    }

    func secondaryStyle(borderColor: UIColor? = nil, borderWidth: CGFloat = 2, isCircular: Bool = true) {
        self.commonTextColorStyle()
        if isCircular {
            self.makeMeCircular()
        } else {
            self.setRadius(all: 8)
        }
        self.setBorder(borderWith: borderWidth, borderColor: borderColor ?? ColorName.primary.color)
        
        if let image = self.image(for: .normal) {
            self.setImage(image.image(with: 0.5), for: .highlighted)
        }
    }
    
    func dangerouseStyle() {
        self.customStyle(with: ColorName.almostRed.color)
    }
    
    func customStyle(with backgroundColor: UIColor?) {
        self.backgroundColor = backgroundColor
        self.setBackgroundColor(backgroundColor, for: .normal)
        self.commonBackgroundStyle()
        self.commonTextColorStyle()
    }
    
    func customBorderStyle(with borderColor: UIColor, border width: CGFloat = 1.5, isCircular: Bool = false) {
        self.commonTextColorStyle()
        if isCircular {
            self.makeMeCircular()
        } else {
            self.setRadius(all: 8)
        }
        self.setBorder(borderWith: width, borderColor: borderColor)
        
        if let image = self.image(for: .normal) {
            self.setImage(image.image(with: 0.5), for: .highlighted)
        }
    }
    
    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        self.setBackgroundImage(color?.toImage(), for: state)
    }
}
