//
//  CenteredImageButton.swift
//  SereyIO
//
//  Created by Panha Uy on 3/25/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

class CenteredImageButton: UIButton {
    
    var spacing: CGFloat = 6

    override func layoutSubviews() {
        super.layoutSubviews()
           
        invalidateTextAlignment()
    }
    
    func invalidateTextAlignment() {
        if let image = self.imageView?.image {
            let imageSize: CGSize = image.size
            self.titleEdgeInsets = UIEdgeInsets(top: spacing, left: -imageSize.width, bottom: -(imageSize.height), right: 0.0)
            let labelString = NSString(string: self.titleLabel!.text!)
            let titleSize = labelString.size(withAttributes: [NSAttributedString.Key.font: self.titleLabel!.font])
            self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width)
        }
    }
}
