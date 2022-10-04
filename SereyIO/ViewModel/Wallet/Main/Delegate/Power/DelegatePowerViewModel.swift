//
//  DelegatePowerViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 11/4/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class DelegatePowerViewModel: BaseInitTransactionViewModel, ShouldPresent, ShouldReactToAction {
    
    enum Action {
        case delegatePressed
    }
    
    enum ViewToPresent {
        case loading(Bool)
        case dismiss
        case confirmDelegatePowerController(ConfirmDelegatePowerViewModel)
        case confirmCancelDelegateController(viewModel: ConfirmDialogViewModel)
        case showAlertDialogController(AlertDialogModel)
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let type: DelegateType
    let titleText: BehaviorSubject<String?>
    let isAmountHidden: BehaviorSubject<Bool>
    let submitButtonTitle: BehaviorSubject<String?>
    
    let accountTextFieldViewModel: TextFieldViewModel
    let amountTextFieldViewModel: TextFieldViewModel
    
    let isDelegateEnabled: BehaviorSubject<Bool>
    
    init(_ type: DelegateType = .delegatePower) {
        self.type = type
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.titleText = .init(value: type.title)
        self.isAmountHidden = .init(value: type == .cancelDelegate)
        self.submitButtonTitle = .init(value: type.buttonTitle)
        
        self.accountTextFieldViewModel = .textFieldWith(title: type.accountPlaceholder + " *", validation: .notEmpty)
        self.amountTextFieldViewModel = .textFieldWith(title: R.string.transfer.amount.localized() + " *", validation: .notEmpty)
        
        self.isDelegateEnabled = .init(value: false)
        super.init()
        
        self.amountTextFieldViewModel.value = type.defaultAmountText
        setUpRxObservers()
    }
}

// MARK: - Networks
extension DelegatePowerViewModel {
    
    private func delegatePower() {
        let account = self.accountTextFieldViewModel.value ?? ""
        let amount = Double(self.amountTextFieldViewModel.value ?? "0") ?? 0.0
        
        self.isLoading.onNext(true)
        self.transferService.delegatePower(account, amount: amount)
            .subscribe(onNext: { [weak self] data in
                self?.isLoading.onNext(false)
                self?.handleDelegateSuccess(account, amount: amount.description)
            }, onError: { [weak self] error in
                self?.isLoading.onNext(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension DelegatePowerViewModel {
    
    func validateForm() -> Bool {
        return self.accountTextFieldViewModel.validate()
        && self.amountTextFieldViewModel.validate()
    }
}

// MARK: - Action Handlers
extension DelegatePowerViewModel {
    
    func handleDelegatePowerPressed() {
        if self.validateForm() {
            let amount = Double(self.amountTextFieldViewModel.value ?? "0") ?? 0.0
            if self.type == .delegatePower && amount <= 30 {
                self.amountTextFieldViewModel.errorText.accept("Amount should be greater than 30")
            } else {
                self.isLoading.onNext(true)
                self.initTransaction(completion: {
                    self.handleConfirmDelegate()
                })
            }
        }
    }
    
    func handleConfirmDelegate() {
        let fromAccount = AuthData.shared.username ?? ""
        let toAccount = self.accountTextFieldViewModel.value ?? ""
        let amount = self.amountTextFieldViewModel.value ?? ""
        if self.type == .delegatePower {
            let confirmDelegatePowerViewModel = ConfirmDelegatePowerViewModel(from: fromAccount, to: toAccount, amount: amount).then {
                $0.confirmed.asObserver()
                    .subscribe(onNext: { [weak self] _ in
                        self?.delegatePower()
                    }).disposed(by: $0.disposeBag)
            }
            self.shouldPresent(.confirmDelegatePowerController(confirmDelegatePowerViewModel))
        } else {
            let title = "Cancel Delegation from \"\(toAccount)\""
            let message = "Are you sure you want to cancel delegate power?"
            let viewModel = ConfirmDialogViewModel(title: title, message: message, action: .init("Cancel Delegate", style: .default, completion: {
                self.delegatePower()
            }))
            self.shouldPresent(.confirmCancelDelegateController(viewModel: viewModel))
        }
    }
    
    func handleDelegateSuccess(_ account: String, amount: String) {
        let confirmAction = ActionModel(R.string.common.confirm.localized(), style: .default) {
            self.shouldPresent(.dismiss)
            self.didTransactionUpdate.onNext(())
        }
        
        let alerDialogModel = AlertDialogModel(title: "Delegate", message: "You’ve just delegate \(amount) Serey Power to \(account).", actions: [confirmAction])
        self.shouldPresent(.showAlertDialogController(alerDialogModel))
    }
}

// MARK: - SetUp RxObservers
extension DelegatePowerViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.accountTextFieldViewModel.textFieldText
            .map { _ in self.validateForm() }
            ~> self.isDelegateEnabled
            ~ self.disposeBag
        
        self.amountTextFieldViewModel.textFieldText
            .map { _ in self.validateForm() }
            ~> self.isDelegateEnabled
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
                case .delegatePressed:
                    self?.handleDelegatePowerPressed()
                }
            }) ~ self.disposeBag
    }
}

// Delegate Type
enum DelegateType {
    
    case delegatePower
    case cancelDelegate
    
    var title: String {
        switch self {
        case .delegatePower:
            return "Delegate My Power"
        case .cancelDelegate:
            return "Cancel Delegation"
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .delegatePower:
            return "Delegate"
        case .cancelDelegate:
            return "Cancel Delegation"
        }
    }
    
    var accountPlaceholder: String {
        switch self {
        case .delegatePower:
            return R.string.transfer.toAccount.localized()
        case .cancelDelegate:
            return "From account"
        }
    }
    
    var defaultAmountText: String {
        switch self {
        case .delegatePower:
            return ""
        case .cancelDelegate:
            return "0"
        }
    }
}
