//
//  ChooseSecurityMethodViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 6/15/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources
import RxBinding

class ChooseSecurityMethodViewModel: BaseCellViewModel, CollectionSingleSecitionProviderModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case itemSelected(IndexPath)
        case setUpLaterPressed
    }
    
    enum ViewToPresent {
        case activeBiometryController(ActiveBiometryViewModel)
        case activeGoogleOTPController(ActivateGoogleOTPViewModel)
        case mainWalletController
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let cells: BehaviorRelay<[CellViewModel]>
    let methods: BehaviorRelay<[SecurityMethod]>
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.cells = .init(value: [])
        self.methods = .init(value: [])
        super.init()
        
        setUpRxObservers()
        self.methods.accept(loadSecurityMethods())
    }
}

// MARK: - Loaders
extension ChooseSecurityMethodViewModel {
    
    func loadSecurityMethods() -> [SecurityMethod] {
        return SecurityMethod.supportedMethods()
    }
}

//MARK: - Preparations & Tools
extension ChooseSecurityMethodViewModel {
    
    func prepareCells(_ data: [SecurityMethod]) -> [CellViewModel] {
        return data.map { SecurityMethodCellViewModel($0) }
    }
}

// MARK: - Action Handlers
fileprivate extension ChooseSecurityMethodViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let item = item(at: indexPath) as? SecurityMethodCellViewModel {
            switch item.method {
            case .faceID, .fingerPrintID:
                let viewModel = ActiveBiometryViewModel(item.method == .faceID ? .faceID : .touchID)
                self.shouldPresent(.activeBiometryController(viewModel))
            case .googleOTP:
                let viewModel = ActivateGoogleOTPViewModel(.signUp)
                self.shouldPresent(.activeGoogleOTPController(viewModel))
            }
        }
    }
}

// MARK: - Set Up RxObservers
extension ChooseSecurityMethodViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.methods.asObservable()
            .map { [unowned self] in self.prepareCells($0) }
            ~> self.cells
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indexPath):
                    self?.handleItemSelected(indexPath)
                case .setUpLaterPressed:
                    self?.shouldPresent(.mainWalletController)
                }
            }) ~ self.disposeBag
    }
}
