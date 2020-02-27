//
//  ChooseCategorySheetViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/26/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class ChooseCategorySheetViewModel: BaseCellViewModel, CollectionSingleSecitionProviderModel {
    
    let categories: BehaviorRelay<[DiscussionCategoryModel]>
    let cells: BehaviorRelay<[CellViewModel]>
    
    init(_ categories: [DiscussionCategoryModel]) {
        self.categories = BehaviorRelay(value: categories)
        self.cells = BehaviorRelay(value: [])
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension ChooseCategorySheetViewModel {
    
    private func prepareCells(_ categories: [DiscussionCategoryModel]) -> [CellViewModel] {
        return categories.map { PostCategoryCellViewModel($0, BehaviorRelay(value: nil)) }
    }
}

// MARK: - SetUp RxOservers
extension ChooseCategorySheetViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.categories.asObservable()
            .map { self.prepareCells($0) }
            ~> self.cells
            ~ self.disposeBag
    }
}
