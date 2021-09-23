//
//  CicularButton.swift
//  SereyIO
//
//  Created by Phanha Uy on 1/3/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

class CircularButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.makeMeCircular()
    }
}
