//
//  CreatePostViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/25/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class CreatePostViewModel: BaseCellViewModel, CollectionSingleSecitionProviderModel, ShouldReactToAction {
    
    enum Action {
        case itemSelected(IndexPath)
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    let cells: BehaviorRelay<[CellViewModel]>
    let selectedCategory: BehaviorRelay<DiscussionCategoryModel?>
    let selectedSubCategory: BehaviorRelay<DiscussionCategoryModel?>
    
    init(_ type: SubmitPostType) {
        self.cells = BehaviorRelay(value: [])
        self.selectedCategory = BehaviorRelay(value: nil)
        self.selectedSubCategory = BehaviorRelay(value: nil)
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension CreatePostViewModel {
    
    enum CategoryCellType {
        case category(DiscussionCategoryModel?)
        case subCategory(DiscussionCategoryModel?)
        
        var cellModel: TextCellViewModel {
            return TextCellViewModel(with: "Select category", properties: .defaultProperties(), indicatorAccessory: true)
        }
    }
    
    fileprivate func prepareCells() -> [CellViewModel] {
        var items: [CategoryCellType] = [.category(self.selectedSubCategory.value)]
        if self.selectedCategory.value != nil {
            items.append(.subCategory(self.selectedSubCategory.value))
        }
        return items.map { $0.cellModel }
    }
}

// MARK: - SetUp RxObservers
extension CreatePostViewModel {
    
    func setUpRxObservers() {
        setUpContentObservers()
    }
    
    func setUpContentObservers() {
        self.selectedCategory.asObservable()
            .map { [unowned self] _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
        
        self.selectedSubCategory.asObservable()
            .map { [unowned self] _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
    }
}

// MARK: - Post Creation Type
enum SubmitPostType {
    
    case edit(PostModel)
    case create
}
