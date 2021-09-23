//
//  LanguageModel.swift
//  Emergency
//
//  Created by Phanha Uy on 9/21/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

class LanguageModel: ImageTextModel {
    
    let isSelected: Bool
    
    init(lanuage: Languages) {
        self.isSelected = lanuage.isSelected
        super.init(image: lanuage.image, titleText: lanuage.languageText)
    }
}
