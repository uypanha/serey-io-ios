//
//  PostCategoryCellViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/26/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class PostCategoryCellViewModel: CellViewModel, CollectionSingleSecitionProviderModel {
    
    let category: BehaviorRelay<DiscussionCategoryModel>
    let selectedCategory: BehaviorRelay<DiscussionCategoryModel?>
    let nameText: BehaviorSubject<String?>
    
    let cells: BehaviorRelay<[CellViewModel]>
    
    init(_ category: DiscussionCategoryModel, _ selectedCategory: BehaviorRelay<DiscussionCategoryModel?>) {
        self.category = BehaviorRelay(value: category)
        self.nameText = BehaviorSubject(value: nil)
        self.selectedCategory = selectedCategory
        self.cells = BehaviorRelay(value: [])
        super.init()
        
        self.notifyDataChanged(category)
    }
    
    func notifyDataChanged(_ data: DiscussionCategoryModel) {
        self.nameText.onNext(data.name)
        self.cells.accept(self.prepareCells(data))
    }
}

// MARK: - Preparations & Tools
extension PostCategoryCellViewModel {
    
    func prepareCells(_ data: DiscussionCategoryModel) -> [CellViewModel] {
        var cellModels: [CellViewModel] = []
        
        let category = self.category.value
        let selectedCategory = self.selectedCategory.value
        cellModels.append(SubCategoryCellViewModel(category, title: "All", isSelected: selectedCategory?.name == category.name))
        
        cellModels.append(contentsOf: (data.sub ?? []).map {
            SubCategoryCellViewModel($0, title: $0.name, isSelected: selectedCategory?.name == $0.name)
        })
        return cellModels
    }
}

// MARK: - Sub Category Cell
class SubCategoryCellViewModel: CellViewModel {
    
    let category: BehaviorRelay<DiscussionCategoryModel>
    let nameText: BehaviorSubject<String?>
    let isSelected: BehaviorRelay<Bool>
    
    init(_ category: DiscussionCategoryModel, title: String, isSelected: Bool) {
        self.category = BehaviorRelay(value: category)
        self.isSelected = BehaviorRelay(value: isSelected)
        self.nameText = BehaviorSubject(value: title)
        super.init()
    }
}

