//
//  PaddingTextField.swift
//  Master Service
//
//  Created by Phanha Uy on 1/14/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

@IBDesignable
class PaddingTextField: UITextField {

    lazy var padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.rightViewRect(forBounds: bounds)
        textRect.origin.x -= 12
        return textRect
    }
}
