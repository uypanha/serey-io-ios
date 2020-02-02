//
//  MDCQuadPageControl.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 2/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import MaterialComponents

class MDCQuadPageControl: MDCPageControl {
    
    @IBInspectable
    var spacing: CGFloat = 8
    
    @IBInspectable
    var itemHeight: CGFloat = 4
    
    @IBInspectable
    var itemWidth: CGFloat = 25
    
    func prepareIndicator() {
        guard subviews.isEmpty else { return }
        
        var total: CGFloat = 0
        
        for view in subviews {
            view.layer.cornerRadius = self.itemHeight / 2
            view.frame = CGRect(x: total, y: frame.size.height / 2 - self.itemHeight / 2, width: self.itemWidth, height: self.itemHeight)
            total += self.itemWidth + self.spacing
        }
        
        total -= self.spacing
        
        frame.origin.x = frame.origin.x + frame.size.width / 2 - total / 2
        frame.size.width = total
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        prepareIndicator()
    }
}
