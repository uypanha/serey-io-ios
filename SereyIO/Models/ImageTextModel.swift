//
//  ImageTextModel.swift
//  Emergency
//
//  Created by Phanha Uy on 9/21/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

class ImageTextModel {
    
    var image: UIImage?
    var titleText: String?
    var subTitle: String?
    
    init(image: UIImage?, titleText: String?, subTitle: String? = nil) {
        self.image = image
        self.titleText = titleText
    }
}
