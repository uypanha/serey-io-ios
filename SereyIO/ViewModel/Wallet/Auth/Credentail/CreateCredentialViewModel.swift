//
//  CreateCredentialViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 6/20/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class CreateCredentialViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case nextPressed
        case skipPressed
    }
    
    enum ViewToPresent {
        case loading(Bool)
        case chooseSecurityMethodController
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let shouldEnbleNext: BehaviorSubject<Bool>
    
    let username: BehaviorRelay<String>
    let ownerKey: BehaviorRelay<String>
    let token: BehaviorRelay<TokenModel>
    
    let passwordTextFieldViewModel: TextFieldViewModel
    let confirmPasswordTextFieldViewModel: TextFieldViewModel
    
    let authService: AuthService
    
    init(_ username: String, ownerKey: String, token: TokenModel) {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.passwordTextFieldViewModel = .textFieldWith(title: "Password", errorMessage: "Please make sure your password is a correct format.", validation: .strongPassword)
        self.confirmPasswordTextFieldViewModel = .textFieldWith(title: "Confirm Password", errorMessage: "Please make sure your passwords match.", validation: .strongPassword)
        self.shouldEnbleNext = .init(value: false)
        
        self.username = .init(value: username)
        self.ownerKey = .init(value: ownerKey)
        self.token = .init(value: token)
        self.authService = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension CreateCredentialViewModel {
    
    func signUpWallet() {
        let username = self.username.value
        let ownerKey = self.ownerKey.value
        let postingPriKey = SereyKeyHelper.generateKey(from: username, ownerKey: ownerKey, type: .posting)?.wif ?? ""
        let password = self.passwordTextFieldViewModel.value ?? ""
        let token = self.token.value.token
        
        self.shouldPresent(.loading(true))
        self.authService.signUpWallet(username: username, postingPriKey: postingPriKey, password: password, requestToken: token)
            .subscribe(onNext: { [weak self] data in
                self?.shouldPresent(.loading(false))
                self?.handleSignUpSuccess(username, ownerKey)
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension CreateCredentialViewModel {
    
    func validateForm() -> Bool {
        return self.passwordTextFieldViewModel.validate()
            && self.confirmPasswordTextFieldViewModel.validate(match: self.passwordTextFieldViewModel.value)
    }
    
    func areFieldsFilled() -> Bool {
        return !(self.passwordTextFieldViewModel.value ?? "").isEmpty &&
            !(self.confirmPasswordTextFieldViewModel.value ?? "").isEmpty
    }
}

// MARK: - Action Handlers
fileprivate extension CreateCredentialViewModel {
    
    func handleNextPressed() {
        if self.validateForm() {
            self.signUpWallet()
        }
    }
    
    func handleSignUpSuccess(_ username: String, _ ownerKey: String) {
        if let activeKey = SereyKeyHelper.generateKey(from: username, ownerKey: ownerKey, type: .active) {
            WalletStore.shared.savePassword(username: username, password: activeKey.wif)
            self.shouldPresent(.chooseSecurityMethodController)
        }
    }
    
    func handleSkipPressed() {
        let username = self.username.value
        let ownerKey = self.ownerKey.value
        if let activeKey = SereyKeyHelper.generateKey(from: username, ownerKey: ownerKey, type: .active) {
            WalletStore.shared.savePassword(username: username, password: activeKey.wif)
            self.shouldPresent(.chooseSecurityMethodController)
        }
    }
}

// MARK: - SetUp RxObservers
extension CreateCredentialViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObsevers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObsevers() {
        self.passwordTextFieldViewModel.textFieldText
            .map { [unowned self] _ in self.areFieldsFilled() }
            ~> self.shouldEnbleNext
            ~ self.disposeBag
        
        self.confirmPasswordTextFieldViewModel.textFieldText
            .map { [unowned self] _ in self.areFieldsFilled() }
            ~> self.shouldEnbleNext
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .nextPressed:
                    self?.handleNextPressed()
                case .skipPressed:
                    self?.handleSkipPressed()
                }
            }) ~ self.disposeBag
    }
}
