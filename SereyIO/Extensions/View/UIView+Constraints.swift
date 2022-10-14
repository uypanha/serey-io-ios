//
//  UIView+Constraints.swift
//  SereyIO
//
//  Created by Panha Uy on 4/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import SnapKit

extension UIView {
    
    func withMinHeight(_ height: CGFloat) {
        self.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(height)
        }
    }
    
    func withMinWidth(_ width: CGFloat) {
        self.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(width)
        }
    }
    
    func withWidth(_ width: CGFloat) {
        self.snp.makeConstraints { make in
            make.width.equalTo(width)
        }
    }
    
    func withHeight(_ height: CGFloat) {
        self.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
    }
    
    func withSize(_ size: CGSize) {
        self.snp.makeConstraints { make in
            make.height.equalTo(size.height)
            make.width.equalTo(size.width)
        }
    }
}
