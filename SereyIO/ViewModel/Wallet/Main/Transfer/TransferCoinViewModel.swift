//
//  TransferCoinViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/4/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class TransferCoinViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {
    
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
    
    let transferService: TransferService
    let userService: UserService
    
    init(_ username: String? = nil) {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.accountTextFieldViewModel = .textFieldWith(title: "To account *", validation: .notEmpty)
        self.amountTextFieldViewModel = .textFieldWith(title: "Amount *", validation: .notEmpty)
        self.memoTextFieldViewModel = .textFieldWith(title: "Description", validation: .none)
        
        self.isUsernameEditable = .init(value: username == nil)
        self.isTransferEnabled = .init(value: false)
        
        self.transferService = .init()
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
                self?.initTransaction()
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
                self?.accountTextFieldViewModel.setError("Username not found")
            }) ~ self.disposeBag
    }
    
    private func initTransaction() {
        self.transferService.initTransaction()
            .subscribe(onNext: { [weak self] data in
                self?.transferService.publicKey = data.publicKey
                self?.transferService.trxId = data.trxId
                self?.shouldPresent(.loading(false))
                self?.handleConfirmTransfer()
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    func tranferCoin() {
        let account = self.accountTextFieldViewModel.value ?? ""
        let amount = self.amountTextFieldViewModel.value ?? "0"
        let memo = self.memoTextFieldViewModel.value ?? ""
        
        self.shouldPresent(.loading(true))
        self.transferService.transferCoin(account, amount: amount, memo: memo)
            .subscribe(onNext: { [weak self] response in
                self?.shouldPresent(.loading(false))
                self?.handleTransferSuccess(account, amount: amount)
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
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
        }
        
        let alerDialogModel = AlertDialogModel(title: "Transfer Coin", message: "You just transfered Serey coin with \(amount) SEREY to \(account).", actions: [confirmAction])
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
