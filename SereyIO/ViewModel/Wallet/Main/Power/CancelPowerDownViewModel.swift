//
//  CancelPowerDownViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 9/4/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class CancelPowerDownViewModel: BaseInitTransactionViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case cancelPowerDownPressed
    }
    
    enum ViewToPresent {
        case loading(Bool)
        case dismiss
        case showAlertDialogController(AlertDialogModel)
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension CancelPowerDownViewModel {
    
    func cancelPowerDown() {
        self.isLoading.onNext(true)
        self.transferService.cancelPower()
            .subscribe(onNext: { [weak self] data in
                self?.isLoading.onNext(false)
                self?.handleCancelPowerSuccess()
            }, onError: { [weak self] error in
                self?.isLoading.onNext(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Action Handlers
fileprivate extension CancelPowerDownViewModel {
    
    func handleCancelPowerDownPressed() {
        self.isLoading.onNext(true)
        self.initTransaction {
            self.cancelPowerDown()
        }
    }
    
    func handleCancelPowerSuccess() {
        let confirmAction = ActionModel(R.string.common.confirm.localized(), style: .default) {
            self.shouldPresent(.dismiss)
            self.didTransactionUpdate.onNext(())
        }
        
        let alerDialogModel = AlertDialogModel(title: "Cancel Power", message: "You just cancel Serey Power.", actions: [confirmAction])
        self.shouldPresent(.showAlertDialogController(alerDialogModel))
    }
}

// MARK: - SetUP RxObservers
extension CancelPowerDownViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
        
        self.isLoading.map { ViewToPresent.loading($0) }
            ~> self.shouldPresentSubject
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .cancelPowerDownPressed:
                    self?.handleCancelPowerDownPressed()
                }
            }) ~ self.disposeBag
    }
}
