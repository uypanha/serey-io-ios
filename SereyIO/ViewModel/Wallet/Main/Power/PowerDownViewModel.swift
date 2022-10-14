//
//  PowerDownViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 9/3/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class PowerDownViewModel: BaseInitTransactionViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case powerDownPressed
    }
    
    enum ViewToPresent {
        case loading(Bool)
        case dismiss
        case confirmPowerDownController(ConfirmPowerViewModel)
        case showAlertDialogController(AlertDialogModel)
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let accountTextFieldViewModel: TextFieldViewModel
    let amountTextFieldViewModel: TextFieldViewModel
    
    let isPowerDownEnabled: BehaviorSubject<Bool>
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.accountTextFieldViewModel = .textFieldWith(title: "From Account" + " *", validation: .notEmpty)
        self.amountTextFieldViewModel = .textFieldWith(title: R.string.transfer.amount.localized() + " *", validation: .notEmpty)
        
        self.isPowerDownEnabled = .init(value: false)
        super.init()
        
        self.accountTextFieldViewModel.value = AuthData.shared.username
        setUpRxObservers()
    }
}

// MARK: - Networks
extension PowerDownViewModel {
    
    private func powerDown() {
        let account = self.accountTextFieldViewModel.value ?? ""
        let amount = self.amountTextFieldViewModel.value ?? "0"
        
        self.isLoading.onNext(true)
        self.transferService.powerDown(amount: Double(amount) ?? 0.0)
            .subscribe(onNext: { [weak self] data in
                self?.isLoading.onNext(false)
                self?.handlePowerDownSuccess(account, amount: amount)
            }, onError: { [weak self] error in
                self?.isLoading.onNext(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension PowerDownViewModel {
    
    func validateForm() -> Bool {
        return self.accountTextFieldViewModel.validate()
            && self.amountTextFieldViewModel.validate()
    }
}

// MARK: - Action Handlers
fileprivate extension PowerDownViewModel {
    
    func handlePowerDownPressed() {
        if self.validateForm() {
            self.isLoading.onNext(true)
            self.initTransaction(completion: {
                self.handleConfirmTransfer()
            })
        }
    }
    
    func handleConfirmTransfer() {
        let amount = self.amountTextFieldViewModel.value ?? "0"
        let confirmPowerViewModel = ConfirmPowerViewModel(from: AuthData.shared.username ?? "", .down(amount: amount)).then {
            $0.confirmed.asObserver()
                .subscribe(onNext: { [weak self] _ in
                    self?.powerDown()
                }).disposed(by: $0.disposeBag)
        }
        self.shouldPresent(.confirmPowerDownController(confirmPowerViewModel))
    }
    
    func handlePowerDownSuccess(_ account: String, amount: String) {
        let confirmAction = ActionModel(R.string.common.confirm.localized(), style: .default) {
            self.shouldPresent(.dismiss)
            self.didTransactionUpdate.onNext(())
        }
        
        let alerDialogModel = AlertDialogModel(title: "Power Down", message: "You’ve just powered down \(amount) Serey Power.", actions: [confirmAction])
        self.shouldPresent(.showAlertDialogController(alerDialogModel))
    }
}

// MARK: - SetUp RxObservers
extension PowerDownViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.accountTextFieldViewModel.textFieldText
            .map { _ in self.validateForm() }
            ~> self.isPowerDownEnabled
            ~ self.disposeBag
        
        self.amountTextFieldViewModel.textFieldText
            .map { _ in self.validateForm() }
            ~> self.isPowerDownEnabled
            ~ self.disposeBag
        
        self.isLoading.asObservable()
            .map { ViewToPresent.loading($0) }
            ~> self.shouldPresentSubject
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .powerDownPressed:
                    self?.handlePowerDownPressed()
                }
            }) ~ self.disposeBag
    }
}
