//
//  SignUpWalletViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 6/18/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import Steem

class SignUpWalletViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case signUpPressed
    }
    
    enum ViewToPresent {
        case createCredentialController
        case loading(Bool)
        case dismiss
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let userNameTextFieldViewModel: TextFieldViewModel
    let ownerKeyTextFieldViewModel: TextFieldViewModel
    let shouldEnbleSignUp: BehaviorSubject<Bool>
    
    let authService: AuthService
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.userNameTextFieldViewModel = .textFieldWith(title: "Username", errorMessage: "", validation: .notEmpty)
        self.ownerKeyTextFieldViewModel = .textFieldWith(title: "Owner Key", errorMessage: "", validation: .notEmpty)
        self.shouldEnbleSignUp = .init(value: false)
        
        self.authService = AuthService()
        super.init()
        
        setUpRxObservers()
        self.userNameTextFieldViewModel.value = AuthData.shared.username
    }
}

// MARK: - Networks
extension SignUpWalletViewModel {
    
    func verifyOwnerKey(_ username: String, _ ownerKey: String) {
        self.shouldPresent(.loading(true))
        self.authService.loginOwner(username, ownerKey)
            .subscribe(onNext: { [weak self] data in
                self?.shouldPresent(.loading(false))
                self?.handleOwnerKeyVerified(username, ownerKey)
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension SignUpWalletViewModel {
    
    private func handleOwnerKeyVerified(_ username: String, _ ownerKey: String) {
        if let activeKey = SereyKeyHelper.generateKey(from: username, ownerKey: ownerKey, type: .active) {
//            WalletStore.shared.savePassword(username: username, password: activeKey.wif)
            self.shouldPresent(.createCredentialController)
        }
    }
    
    func validateForm() -> Bool {
        return self.userNameTextFieldViewModel.validate()
            && self.ownerKeyTextFieldViewModel.validate()
    }
    
    func areFieldsFilled() -> Bool {
        return !(self.userNameTextFieldViewModel.value ?? "").isEmpty &&
            !(self.ownerKeyTextFieldViewModel.value ?? "").isEmpty
    }
}

// MARK: - Action Handlers
fileprivate extension SignUpWalletViewModel {
    
    func handleSignUpPressed() {
        if self.validateForm() {
            let username = self.userNameTextFieldViewModel.value ?? ""
            let ownerKey = self.ownerKeyTextFieldViewModel.value ?? ""
            self.verifyOwnerKey(username, ownerKey)
        }
    }
}

// MARK: - SetUp RxObservers
extension SignUpWalletViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObsevers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObsevers() {
        self.userNameTextFieldViewModel.textFieldText
            .map { [unowned self] _ in self.areFieldsFilled() }
            ~> self.shouldEnbleSignUp
            ~ self.disposeBag
        
        self.ownerKeyTextFieldViewModel.textFieldText
            .map { [unowned self] _ in self.areFieldsFilled() }
            ~> self.shouldEnbleSignUp
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .signUpPressed:
                    self?.handleSignUpPressed()
                }
            }) ~ self.disposeBag
    }
}
