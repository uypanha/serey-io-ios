//
//  UIRightIconButton.swift
//  SereyIO
//
//  Created by Panha Uy on 8/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class UIRightIconButton: UIButton {
    
    @IBInspectable
    var imageCircular: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentHorizontalAlignment = .left
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageView = self.imageView {
            let x = self.frame.width - 16 - imageView.frame.width
            imageView.frame = CGRect(origin: CGPoint(x: x, y: imageView.frame.origin.y), size: imageView.frame.size)
            
            if imageCircular {
                imageView.makeMeCircular()
            } else {
                imageView.setRadius(all: 0)
            }
        }
    }
}
