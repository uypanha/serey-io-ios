//
//  DashBorderView.swift
//  SereyIO
//
//  Created by Mäd on 28/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit

class DashBorderView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            reloadView()
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            reloadView()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet {
            reloadView()
        }
    }
    
    fileprivate func reloadView() {
        configureCardView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        reloadView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        reloadView()
    }
    
    func configureCardView() {
        self.setRadius(all: self.cornerRadius)
        self.removeDashedBorder()
        self.addDashedBorder(width: nil, height: nil, lineWidth: self.borderWidth, lineDashPattern: [6, 4], strokeColor: self.borderColor ?? .clear, fillColor: .clear)
    }
}
