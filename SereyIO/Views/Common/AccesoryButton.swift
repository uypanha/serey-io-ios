//
//  AccesoryButton.swift
//  SereyIO
//
//  Created by Panha Uy on 7/9/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit

@IBDesignable
class AccesoryButton: UIButton {

    @IBInspectable var leftHandImage: UIImage? {
        didSet {
            setupImages()
        }
    }
    @IBInspectable var rightHandImage: UIImage? {
        didSet {
            setupImages()
        }
    }
    var rightImageView: UIImageView? = nil
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupImages()
    }

    func setupImages() {
        self.rightImageView?.removeFromSuperview()
        if let leftImage = leftHandImage {
            self.setImage(leftImage, for: .normal)
            self.imageView?.contentMode = .scaleAspectFill
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: self.frame.width - (self.imageView?.frame.width)!)
        }

        if let rightImage = rightHandImage {
            self.rightImageView = UIImageView(image: rightImage)
            rightImageView?.tintColor = self.tintColor

            let height = rightImage.size.height
            let width = rightImage.size.width
            let xPos = self.frame.width - width - 8
            let yPos = (self.frame.height - height) / 2

            rightImageView?.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
            self.addSubview(rightImageView!)
        }
    }
}
