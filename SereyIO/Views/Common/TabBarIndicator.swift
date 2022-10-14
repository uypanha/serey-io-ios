//
//  TabBarIndicator.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/3/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import MaterialComponents

class TabBarIndicator: NSObject, MDCTabBarViewIndicatorTemplate {
    
    private let underlineHeight: CGFloat = 4
    private let cornerRadius: CGFloat = 8
    private let padding: CGFloat = 16
    
    func indicatorAttributes(for context: MDCTabBarViewIndicatorContext) -> MDCTabBarViewIndicatorAttributes {
        let bounds = context.bounds
        let attributes = MDCTabBarViewIndicatorAttributes()
        let lineFrame = CGRect(x: bounds.minX + padding, y: bounds.maxY - underlineHeight, width: bounds.width - (padding * 2), height: underlineHeight)
        attributes.path = UIBezierPath(roundedRect: lineFrame, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        return attributes
    }
}
