//
//  CategoryCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/30/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

class CategoryCellViewModel: TextCellViewModel {
    
    let category: DiscussionCategoryModel
    
    init(_ category: DiscussionCategoryModel, indicatorAccessory: Bool) {
        self.category = category
        super.init(with: category.name, properties: .defaultProperties(), indicatorAccessory: indicatorAccessory)
    }
}
