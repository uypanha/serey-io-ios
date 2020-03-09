//
//  FilteredCategoryCellViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/29/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class FilteredCategoryCellViewModel: CellViewModel, ShouldReactToAction {
    
    enum Action {
        case removeFilterPressed
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    let category: BehaviorRelay<DiscussionCategoryModel>
    let nameText: BehaviorSubject<String?>
    let shouldRemoveFilter: PublishSubject<DiscussionCategoryModel>
    
    init(_ category: DiscussionCategoryModel) {
        self.category = BehaviorRelay(value: category)
        self.nameText = BehaviorSubject(value: nil)
        self.shouldRemoveFilter = PublishSubject()
        super.init()
        
        setUpRxObservers()
        self.nameText.onNext(category.name)
    }
}

// MARK: - Action Handlers
fileprivate extension FilteredCategoryCellViewModel {
    
    func handleRemoveFilterPressed() {
        self.shouldRemoveFilter.onNext(self.category.value)
    }
}

// MARK: - SetUp RxObservers
fileprivate extension FilteredCategoryCellViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .removeFilterPressed:
                    self?.handleRemoveFilterPressed()
                }
            }) ~ self.disposeBag
    }
}
