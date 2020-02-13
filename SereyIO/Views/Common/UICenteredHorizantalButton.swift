//
//  UICenteredHorizantalButton.swift
//  Serey.io
//
//  Created by Phanha Uy on 1/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class UICenteredHorizantalButton: UIButton {
    
    @IBInspectable
    var imageCircular: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentHorizontalAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageView = self.imageView {
            imageView.frame = CGRect(origin: CGPoint(x: 16, y: imageView.frame.origin.y), size: imageView.frame.size)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageView.frame.width, bottom: 0, right: 0)
            
            if imageCircular {
                imageView.makeMeCircular()
            } else {
                imageView.setRadius(all: 0)
            }
        }
    }
}
