//
//  CircularView.swift
//  SereyIO
//
//  Created by Phanha Uy on 12/17/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

class CircularView: CardView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.cornerRadius = self.frame.height / 2
    }
}
