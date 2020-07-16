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

class ChooseCategorySheetViewModel: BaseCellViewModel, CollectionSingleSecitionProviderModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case allCategoryPressed
    }
    
    enum ViewToPresent {
        case dismiss
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let categories: BehaviorRelay<[DiscussionCategoryModel]>
    let selectedCategory: BehaviorRelay<DiscussionCategoryModel?>
    
    let cells: BehaviorRelay<[CellViewModel]>
    let categoryDidSelected: PublishSubject<DiscussionCategoryModel?>
    
    init(_ categories: [DiscussionCategoryModel], _ selectedCategory: DiscussionCategoryModel?) {
        self.categories = BehaviorRelay(value: categories)
        self.selectedCategory = BehaviorRelay(value: selectedCategory)
        
        self.cells = BehaviorRelay(value: [])
        self.categoryDidSelected = PublishSubject()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension ChooseCategorySheetViewModel {
    
    private func prepareCells(_ categories: [DiscussionCategoryModel]) -> [CellViewModel] {
        return categories.map { PostCategoryCellViewModel($0, self.selectedCategory) }
    }
}

// MARK: - SetUp RxOservers
extension ChooseCategorySheetViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.categories.asObservable()
            .map { self.prepareCells($0) }
            ~> self.cells
            ~ self.disposeBag
        
        self.selectedCategory.skip(1)
            .subscribe(onNext: { [weak self] selectedCategory in
                self?.categoryDidSelected.onNext(selectedCategory)
                self?.shouldPresent(.dismiss)
            }) ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .allCategoryPressed:
                    self?.selectedCategory.accept(nil)
                }
            }) ~ self.disposeBag
    }
}
