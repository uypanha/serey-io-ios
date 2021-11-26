//
//  ImageTextModel.swift
//  Emergency
//
//  Created by Phanha Uy on 9/21/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

class ImageTextModel {
    
    var image: UIImage?
    var imageUrl: String?
    var titleText: String?
    var subTitle: String?
    
    init(image: UIImage? = nil, imageUrl: String? = nil, titleText: String?, subTitle: String? = nil) {
        self.image = image
        self.imageUrl = imageUrl
        self.titleText = titleText
        self.subTitle = subTitle
    }
}
