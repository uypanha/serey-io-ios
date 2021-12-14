//
//  ProductCategoryCellViewModel.swift
//  SereyMarket
//
//  Created by Panha Uy on 5/9/21.
//  Copyright © 2021 Serey Marketplace. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class ProductCategoryCellViewModel: CellViewModel {
    
    let category: BehaviorRelay<DiscussionCategoryModel>
    let cateoryName: BehaviorRelay<String?>
    
    let selectedCategory: BehaviorRelay<DiscussionCategoryModel?>
    let isSelected: BehaviorRelay<Bool>
    
    init(_ category: DiscussionCategoryModel, selectedCategory: BehaviorRelay<DiscussionCategoryModel?>, title: String? = nil) {
        self.category = .init(value: category)
        self.cateoryName = .init(value: title ?? category.name)
        self.isSelected = .init(value: false)
        self.selectedCategory = selectedCategory
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - SetUp RxObservers
extension ProductCategoryCellViewModel {
    
    func setUpRxObservers() {
        self.selectedCategory.asObservable()
            .map { $0?.name == self.category.value.name }
            ~> self.isSelected
            ~ self.disposeBag
    }
}
