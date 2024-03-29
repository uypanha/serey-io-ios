//
//  TransferCoinViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/4/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class TransferCoinViewModel: BaseInitTransactionViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case transferPressed
    }
    
    enum ViewToPresent {
        case loading(Bool)
        case showAlertDialogController(AlertDialogModel)
        case confirmTransferController(ConfirmTransferViewModel)
        case dismiss
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let accountTextFieldViewModel: TextFieldViewModel
    let amountTextFieldViewModel: TextFieldViewModel
    let memoTextFieldViewModel: TextFieldViewModel
    
    let isUsernameEditable: BehaviorRelay<Bool>
    let isTransferEnabled: BehaviorSubject<Bool>
    
    let userService: UserService
    
    init(_ username: String? = nil) {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.accountTextFieldViewModel = .textFieldWith(title: R.string.transfer.toAccount.localized() + " *", validation: .notEmpty)
        self.amountTextFieldViewModel = .textFieldWith(title: R.string.transfer.amount.localized() + " *", placeholder: "0.00", validation: .notEmpty)
        self.memoTextFieldViewModel = .textFieldWith(title: R.string.common.description.localized(), validation: .none)
        
        self.isUsernameEditable = .init(value: username == nil)
        self.isTransferEnabled = .init(value: false)
        
        self.userService = .init()
        super.init()
        
        self.accountTextFieldViewModel.value = username
        setUpRxObservers()
    }
}

// MARK: - Networks
extension TransferCoinViewModel {
    
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
    
    func tranferCoin() {
        let account = self.accountTextFieldViewModel.value ?? ""
        let amount = self.amountTextFieldViewModel.value ?? "0"
        let memo = self.memoTextFieldViewModel.value ?? ""
        
        self.isLoading.onNext(true)
        self.transferService.transferCoin(account, amount: Double(amount) ?? 0.0, memo: memo)
            .subscribe(onNext: { [weak self] response in
                self?.isLoading.onNext(false)
                self?.handleTransferSuccess(account, amount: amount)
            }, onError: { [weak self] error in
                self?.isLoading.onNext(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension TransferCoinViewModel {
    
    func validateForm() -> Bool {
        return self.accountTextFieldViewModel.validate()
            && self.amountTextFieldViewModel.validate()
            && self.memoTextFieldViewModel.validate()
    }
}

// MARK: - Action Handlers
fileprivate extension TransferCoinViewModel {
    
    func handleTransferSuccess(_ account: String, amount: String) {
        let confirmAction = ActionModel(R.string.common.confirm.localized(), style: .default) {
            self.shouldPresent(.dismiss)
            self.didTransactionUpdate.onNext(())
        }
        
        let alerDialogModel = AlertDialogModel(title: "Transfer Coin", message: "You’ve just transferred \(amount) Serey Coins to \(account).", actions: [confirmAction])
        self.shouldPresent(.showAlertDialogController(alerDialogModel))
    }
    
    func handleTransferPressed() {
        if self.validateForm() {
            let account = self.accountTextFieldViewModel.value ?? ""
            self.validateUsername(account)
        }
    }
    
    func handleConfirmTransfer() {
        let account = self.accountTextFieldViewModel.value ?? ""
        let amount = self.amountTextFieldViewModel.value ?? "0"
        let memo = self.memoTextFieldViewModel.value ?? ""
        
        let confirmTransferViewModel = ConfirmTransferViewModel(from: AuthData.shared.username ?? "", to: account, amount: amount, memo: memo).then {
            $0.confirmed.asObserver()
                .subscribe(onNext: { [weak self] _ in
                    self?.tranferCoin()
                }).disposed(by: $0.disposeBag)
        }
        self.shouldPresent(.confirmTransferController(confirmTransferViewModel))
    }
}

// MARK: - Set Up RxObservers
extension TransferCoinViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.accountTextFieldViewModel.textFieldText
            .map { _ in self.validateForm() }
            ~> self.isTransferEnabled
            ~ self.disposeBag
        
        self.amountTextFieldViewModel.textFieldText
            .map { _ in self.validateForm() }
            ~> self.isTransferEnabled
            ~ self.disposeBag
        
        self.memoTextFieldViewModel.textFieldText
            .map { _ in self.validateForm() }
            ~> self.isTransferEnabled
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
                case .transferPressed:
                    self?.handleTransferPressed()
                }
            }) ~ self.disposeBag
    }
}
