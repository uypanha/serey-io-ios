//
//  CardView.swift
//  SereyIO
//
//  Created by Phanha Uy on 12/17/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {
    
    override var bounds: CGRect {
        didSet {
            reloadView()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            reloadView()
        }
    }
    
    @IBInspectable var showShadow: Bool = true {
        didSet {
            reloadView()
        }
    }
    
    @IBInspectable var shadowOffsetWidth: Int = 0 {
        didSet {
            reloadView()
        }
    }
    
    @IBInspectable var shadowOffsetHeight: Int = 3 {
        didSet {
            reloadView()
        }
    }
    
    @IBInspectable var shadowColor: UIColor? = UIColor.black {
        didSet {
            reloadView()
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.3 {
        didSet {
            reloadView()
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            reloadView()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            reloadView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        reloadView()
    }
    
    fileprivate func reloadView() {
        configureCardView()
    }
    
    func configureCardView() {
        setRadius(all: cornerRadius)
        
        if showShadow {
            self.layer.masksToBounds = false
            let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            self.layer.shadowColor = shadowColor?.cgColor
            self.layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
            self.layer.shadowOpacity = shadowOpacity
            self.layer.shadowPath = shadowPath.cgPath
        } else {
            self.layer.masksToBounds = true
            self.layer.shadowColor = UIColor.clear.cgColor
            self.layer.shadowOpacity = 0.0
        }
        
        self.setBorder(borderWith: borderWidth, borderColor: borderColor)
    }
}
