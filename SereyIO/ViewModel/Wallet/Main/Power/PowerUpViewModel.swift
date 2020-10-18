//
//  PowerUpViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/27/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class PowerUpViewModel: BaseInitTransactionViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case upToMySelfPressed
        case powerUpPressed
    }
    
    enum ViewToPresent {
        case loading(Bool)
        case dismiss
        case confirmPowerUpController(ConfirmPowerViewModel)
        case showAlertDialogController(AlertDialogModel)
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let accountTextFieldViewModel: TextFieldViewModel
    let amountTextFieldViewModel: TextFieldViewModel
    
    let isPowerUpEnabled: BehaviorSubject<Bool>
    
    let userService: UserService

    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.accountTextFieldViewModel = .textFieldWith(title: R.string.transfer.toAccount.localized() + " *", validation: .notEmpty)
        self.amountTextFieldViewModel = .textFieldWith(title: R.string.transfer.amount.localized() + " *", validation: .notEmpty)
        
        self.isPowerUpEnabled = .init(value: false)
        
        self.userService = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension PowerUpViewModel {
    
    private func validateUsername(_ username: String) {
        self.shouldPresent(.loading(true))
        self.userService.fetchProfile(username)
            .subscribe(onNext: { [weak self] _ in
                self?.initTransaction(completion: {
                    self?.handleConfirmTransfer()
                })
            }, onError: { [weak self] error in
                self?.isLoading.onNext(false)
                self?.accountTextFieldViewModel.setError("Username not found")
            }) ~ self.disposeBag
    }
    
    private func powerUp() {
        let account = self.accountTextFieldViewModel.value ?? ""
        let amount = self.amountTextFieldViewModel.value ?? "0"
        
        self.isLoading.onNext(true)
        self.transferService.powerUp(account, amount: Double(amount) ?? 0.0)
            .subscribe(onNext: { [weak self] data in
                self?.isLoading.onNext(false)
                self?.handlePowerUpSuccess(account, amount: amount)
            }, onError: { [weak self] error in
                self?.isLoading.onNext(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension PowerUpViewModel {
    
    func validateForm() -> Bool {
        return self.accountTextFieldViewModel.validate()
            && self.amountTextFieldViewModel.validate()
    }
}

// MARK: - Action Handlers
fileprivate extension PowerUpViewModel {
    
    func handlePowerUpPressed() {
        if self.validateForm() {
            let account = self.accountTextFieldViewModel.value ?? ""
            if account != AuthData.shared.username {
                self.handleDifferentAccountRequest(account)
            } else {
                self.validateUsername(account)
            }
        }
    }
    
    func handleDifferentAccountRequest(_ account: String) {
        let confirmAction = ActionModel(R.string.common.confirm.localized()) {
            self.validateUsername(account)
        }
        
        let cancelAction = ActionModel(R.string.common.cancel.localized(), style: .cancel)
        let alertDialogModel = AlertDialogModel(title: "Power Up", message: "This transaction cannot be reversed. Are you sure you want to send your serey coin as serey power to another user?", actions: [cancelAction, confirmAction])
        self.shouldPresent(.showAlertDialogController(alertDialogModel))
    }
    
    func handleConfirmTransfer() {
        let account = self.accountTextFieldViewModel.value ?? ""
        let amount = self.amountTextFieldViewModel.value ?? "0"
        let confirmPowerViewModel = ConfirmPowerViewModel(from: AuthData.shared.username ?? "", .up(account: account, amount: amount)).then {
            $0.confirmed.asObserver()
                .subscribe(onNext: { [weak self] _ in
                    self?.powerUp()
                }).disposed(by: $0.disposeBag)
        }
        self.shouldPresent(.confirmPowerUpController(confirmPowerViewModel))
    }
    
    func handlePowerUpSuccess(_ account: String, amount: String) {
        let confirmAction = ActionModel(R.string.common.confirm.localized(), style: .default) {
            self.shouldPresent(.dismiss)
            self.didTransactionUpdate.onNext(())
        }
        
        let alerDialogModel = AlertDialogModel(title: "Power Up", message: "You just power Up Serey coin with \(amount) SEREY to \(account).", actions: [confirmAction])
        self.shouldPresent(.showAlertDialogController(alerDialogModel))
    }
}

// MARK: - SetUp RxObservers
extension PowerUpViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.accountTextFieldViewModel.textFieldText
            .map { _ in self.validateForm() }
            ~> self.isPowerUpEnabled
            ~ self.disposeBag
        
        self.amountTextFieldViewModel.textFieldText
            .map { _ in self.validateForm() }
            ~> self.isPowerUpEnabled
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
                case .powerUpPressed:
                    self?.handlePowerUpPressed()
                case .upToMySelfPressed:
                    self?.accountTextFieldViewModel.value = AuthData.shared.username
                }
            }) ~ self.disposeBag
    }
}
