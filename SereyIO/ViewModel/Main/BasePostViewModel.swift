//
//  BasePostViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/14/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class BasePostViewModel: BaseCellViewModel, CollectionMultiSectionsProviderModel {
    
    let cells: BehaviorRelay<[SectionItem]>
    let emptyOrError: BehaviorSubject<EmptyOrErrorViewModel?>
    
    override init() {
        self.cells = BehaviorRelay(value: [])
        self.emptyOrError = BehaviorSubject(value: nil)
        super.init()
        
        setUpRxObservers()
        self.cells.accept(self.prepareCells())
    }
    
    open func prepareEmptyViewModel() -> EmptyOrErrorViewModel {
        let title = "No Post Yet!"
        let emptyMessage = "Your post will be shown here after you\nmade a post."
        return EmptyOrErrorViewModel(withErrorEmptyModel: EmptyOrErrorModel(withEmptyTitle: title, emptyDescription: emptyMessage, iconImage: R.image.emptyPost()))
    }
}

// MARK: - Preparations & Tools
extension BasePostViewModel {
    
    fileprivate func prepareCells() -> [SectionItem] {
//        let cells = (0...10).map { _ in PostCellViewModel() }
//        return [SectionItem(items: cells)]
        return []
    }
}

// MARK: - SetUp RxObservers
fileprivate extension BasePostViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.cells.asObservable()
            .subscribe(onNext: { [unowned self] cells in
                if cells.isEmpty {
                    self.emptyOrError.onNext(self.prepareEmptyViewModel())
                }
            }) ~ self.disposeBag
    }
}

