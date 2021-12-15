//
//  StyleProtocol.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import MaterialComponents

protocol StyleProtocol {
    
    func primaryStyle()
    
    func secondaryStyle()
    
    func dangerouseStyle()
}

// MARK: - MDCOutlinedTextField {
extension MDCOutlinedTextField: StyleProtocol {
    
    fileprivate func prepareContainerScheme() -> MDCContainerScheme {
        let containerScheme = MDCContainerScheme()
        let colorScheme = MDCSemanticColorScheme()
        colorScheme.surfaceColor = ColorName.primary.color
        colorScheme.primaryColor = ColorName.primary.color
        colorScheme.errorColor = .red
        containerScheme.colorScheme = colorScheme
        return containerScheme
    }
    
    func primaryStyle() {
        applyTheme(withScheme: prepareContainerScheme())
        self.containerRadius = 8
        self.font = UIFont.systemFont(ofSize: 14)
        setOutlineColor(.lightGray, for: .normal)
        setOutlineColor(.lightGray, for: .disabled)
        setNormalLabelColor(.gray, for: .normal)
    }
    
    func secondaryStyle() {
    }
    
    func dangerouseStyle() {
        applyErrorTheme(withScheme: prepareContainerScheme())
        self.font = UIFont.systemFont(ofSize: 14)
        setOutlineColor(.lightGray, for: .normal)
        setOutlineColor(.lightGray, for: .disabled)
        setNormalLabelColor(.gray, for: .normal)
    }
}

// MARK: - Buttons
extension UIButton: StyleProtocol {
    
    private func commonBackgroundStyle() {
        if self.backgroundColor != nil && self.backgroundColor != .clear {
            self.setRadius(all: 8)
            self.setBackgroundColor(ColorName.disabled.color, for: .disabled)
            self.setBackgroundColor(self.backgroundColor!.withAlphaComponent(0.5), for: .highlighted)
        } else {
            self.setBackgroundColor(nil, for: .disabled)
            self.setBackgroundColor(nil, for: .highlighted)
        }
        
        if let image = self.image(for: .normal) {
            if image.renderingMode == .alwaysOriginal {
                self.setImage(image.image(with: 0.5), for: .highlighted)
            } else {
                self.setImage(image.image(withTintColor: self.tintColor.withAlphaComponent(0.5)), for: .highlighted)
            }
        } else {
            self.setImage(nil, for: .highlighted)
        }
    }
    
    func commonTextColorStyle() {
        self.setTitleColor(self.titleColor(for: .normal)?.withAlphaComponent(0.5), for: .highlighted)
        self.setTitleColor(self.titleColor(for: .normal)?.withAlphaComponent(0.3), for: .disabled)
    }
    
    func primaryStyle() {
        self.setTitleColor(.white, for: .normal)
        self.customStyle(with: ColorName.primary.color)
    }
    
    func secondaryStyle() {
        self.tintColor = ColorName.primary.color
        self.setTitleColor(ColorName.primary.color, for: .normal)
        self.customStyle(with: ColorName.lightPrimary.color)
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
            if image.renderingMode == .alwaysOriginal {
                self.setImage(image.image(with: 0.5), for: .highlighted)
            } else {
                self.setImage(image.image(withTintColor: self.tintColor.withAlphaComponent(0.5)), for: .highlighted)
            }
        } else {
            self.setImage(nil, for: .highlighted)
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
        self.customStyle(with: .clear)
        if isCircular {
            self.makeMeCircular()
        } else {
            self.setRadius(all: 8)
        }
        self.setBorder(borderWith: width, borderColor: borderColor)
        
        if let image = self.image(for: .normal) {
            self.setImage(image.image(withTintColor: self.tintColor.withAlphaComponent(0.5)), for: .highlighted)
        } else {
            self.setImage(nil, for: .highlighted)
        }
    }
    
    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        if let color = color, color != .clear {
            self.setBackgroundImage(color.toImage(), for: state)
        } else {
            self.setBackgroundImage(nil, for: state)
        }
    }
}
