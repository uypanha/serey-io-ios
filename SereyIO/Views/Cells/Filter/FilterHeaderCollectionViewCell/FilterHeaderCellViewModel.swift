//
//  FilterHeaderCellViewModel.swift
//  SereyMarket
//
//  Created by Panha Uy on 5/10/21.
//  Copyright © 2021 Serey Marketplace. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class FilterHeaderCellViewModel: CellViewModel {
    
    let selectedCategory: BehaviorRelay<DiscussionCategoryModel?>
    let isResetEnabled: BehaviorSubject<Bool>
    let shouldDismiss: PublishSubject<Void>
    
    init(_ selectedCategory: BehaviorRelay<DiscussionCategoryModel?>) {
        self.selectedCategory = selectedCategory
        self.isResetEnabled = .init(value: false)
        self.shouldDismiss = .init()
        super.init()
        
        setUpRxObservers()
    }
    
    func resetPressed() {
        self.selectedCategory.accept(nil)
        self.shouldDismiss.onNext(())
    }
}

// MARK: - SetUp RxObservers
extension FilterHeaderCellViewModel {
    
    func setUpRxObservers() {
        self.selectedCategory.asObservable()
            .map { $0 != nil }
            ~> self.isResetEnabled
            ~ self.disposeBag
    }
}
