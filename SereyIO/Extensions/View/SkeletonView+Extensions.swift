//
//  SkeletonView+Extensions.swift
//  SereyIO
//
//  Created by Panha on 31/1/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import SkeletonView

extension UIView {
    
    func setSkeletonView(_ show: Bool) {
        if show {
            self.showAnimatedSkeleton()
        } else {
            self.hideSkeleton()
        }
    }
}
