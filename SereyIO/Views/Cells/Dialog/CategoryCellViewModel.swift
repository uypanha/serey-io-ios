//
//  CategoryCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/7/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class CategoryCellViewModel: TextCellViewModel {
    
    let category: BehaviorRelay<DiscussionCategoryModel>
    let isSelected: BehaviorRelay<Bool>
    
    init(_ category: DiscussionCategoryModel, title: String, isSelected: Bool, indicatorAccessory: Bool = true) {
        self.category = BehaviorRelay(value: category)
        self.isSelected = BehaviorRelay(value: isSelected)
        super.init(with: title, properties: .defaultProperties(), indicatorAccessory: indicatorAccessory, isSelectionEnabled: false)
    }
    
    convenience required init(_ isShimmering: Bool) {
        fatalError("init(_:) has not been implemented")
    }
}
