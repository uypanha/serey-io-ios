//
//  NSLayoutConstraint+Multiplier.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

public extension NSLayoutConstraint {
    
    func changeMultiplier(multiplier: CGFloat) -> NSLayoutConstraint? {
        if let firstItem = self.firstItem {
            let newConstraint = NSLayoutConstraint(
                item: firstItem,
                attribute: firstAttribute,
                relatedBy: relation,
                toItem: secondItem,
                attribute: secondAttribute,
                multiplier: multiplier,
                constant: constant)
            newConstraint.priority = priority
            
            NSLayoutConstraint.deactivate([self])
            NSLayoutConstraint.activate([newConstraint])
            
            return newConstraint
        }
        
        return nil
    }
    
}
