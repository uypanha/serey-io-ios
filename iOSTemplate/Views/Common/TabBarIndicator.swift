//
//  TabBarIndicator.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 2/3/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import MaterialComponents

class TabBarIndicator: NSObject, MDCTabBarIndicatorTemplate {
    
    private let underlineHeight: CGFloat = 4
    private let cornerRadius: CGFloat = 8
    private let padding: CGFloat = 16
    
    func indicatorAttributes(for context: MDCTabBarIndicatorContext) -> MDCTabBarIndicatorAttributes {
        let bounds = context.bounds
        let attributes = MDCTabBarIndicatorAttributes()
        let lineFrame = CGRect(x: bounds.minX + padding, y: bounds.maxY - underlineHeight, width: bounds.width - (padding * 2), height: underlineHeight)
        attributes.path = UIBezierPath(roundedRect: lineFrame, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        return attributes
    }
}
