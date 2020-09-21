//
//  AskToCreateCredentialViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 7/26/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class AskToCreateCredentialViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent, CollectionSingleSecitionProviderModel {

    enum Action {
        case skipPressed
        case itemSelected(IndexPath)
    }
    
    enum ViewToPresent {
        case createCredentialViewController
        case setUpSecurityMethodController
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let cells: BehaviorRelay<[CellViewModel]>
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.cells = .init(value: [])
        super.init()
        
        setUpRxObservers()
        self.cells.accept(self.prepareCells())
    }
}

// MARK: - Preparations & Tools
extension AskToCreateCredentialViewModel {
    
    private func prepareCells() -> [CellViewModel] {
        return [CreateCredentialCellViewModel()]
    }
}

// MARK: - Action Handlers
fileprivate extension AskToCreateCredentialViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let _ = item(at: indexPath) as? CreateCredentialCellViewModel {
            self.shouldPresent(.createCredentialViewController)
        }
    }
}

// MARK: - SetUp RxObservers
extension AskToCreateCredentialViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .skipPressed:
                    self?.shouldPresent(.setUpSecurityMethodController)
                case .itemSelected(let indexPath):
                    self?.handleItemSelected(indexPath)
                }
            }) ~ self.disposeBag
    }
}
