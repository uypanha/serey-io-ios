//
//  TransactionHistoryViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/5/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class TransactionHistoryViewModel: BaseCellViewModel, CollectionMultiSectionsProviderModel, ShouldPresent {
    
    enum ViewToPresent {
        case emptyResult(EmptyOrErrorViewModel)
    }
    
    // input:
    //    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    let cells: BehaviorRelay<[SectionItem]>
    
    let transferService: TransferService
    
    override init() {
        self.shouldPresentSubject = .init()
        self.cells = .init(value: [])
        self.transferService = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension TransactionHistoryViewModel {
    
    func downloadData() {
        self.cells.accept([])
    }
}

// MARK: - Preparations & Tools
extension TransactionHistoryViewModel {
    
    fileprivate func prepareEmptyViewModel() -> EmptyOrErrorViewModel {
        let title: String = "You don’t have any transactions"
        let emptyMessage: String = "Send SRY or Power Up to any account and you’ll see transactions here."
        let emptyModel = EmptyOrErrorModel(withEmptyTitle: title, emptyDescription: emptyMessage, iconImage: R.image.emptyTransaction(), actionTitle: "Refresh", actionCompletion: { [unowned self] in
            self.downloadData()
        })
        return EmptyOrErrorViewModel(withErrorEmptyModel: emptyModel)
    }
    
    open func prepareEmptyViewModel(_ erroInfo: ErrorInfo) -> EmptyOrErrorViewModel {
        return EmptyOrErrorViewModel(withErrorEmptyModel: EmptyOrErrorModel(withErrorInfo: erroInfo, actionTitle: R.string.common.tryAgain.localized(), actionCompletion: { [unowned self] in
            self.downloadData()
        }))
    }
}

// MARK: - SetUp RxObservers
fileprivate extension TransactionHistoryViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
//        self.people.asObservable()
//            .map { self.prepareCells($0) }
//            .bind(to: self.cells)
//            .disposed(by: self.disposeBag)

        self.cells.asObservable()
            .subscribe(onNext: { [unowned self] cells in
                if cells.isEmpty {
                    self.shouldPresent(.emptyResult(self.prepareEmptyViewModel()))
                }
            }) ~ self.disposeBag
    }
    
    func setUpActionObservers() {
//        self.didActionSubject.asObservable()
//            .subscribe(onNext: { [weak self] action in
//                switch action {
//                case .itemSelected(let indexPath):
//                    self?.handleItemSelected(indexPath)
//                case .searchEditingChanged:
//                    self?.handleEditingChanged()
//                }
//            }).disposed(by: self.disposeBag)
    }
}
