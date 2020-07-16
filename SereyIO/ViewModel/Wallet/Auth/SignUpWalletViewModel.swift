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

class SignUpWalletViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case signUpPressed
        case backToSignInPressed
    }
    
    enum ViewToPresent {
        case createCredentialController(CreateCredentialViewModel)
        case dismiss
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let userNameTextFieldViewModel: TextFieldViewModel
    let ownerKeyTextFieldViewModel: TextFieldViewModel
    let shouldEnbleSignUp: BehaviorSubject<Bool>
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.userNameTextFieldViewModel = .textFieldWith(title: "Username", errorMessage: "", validation: .notEmpty)
        self.ownerKeyTextFieldViewModel = .textFieldWith(title: "Owner Key", errorMessage: "", validation: .notEmpty)
        self.shouldEnbleSignUp = .init(value: false)
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension SignUpWalletViewModel {
    
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
        let createCredentialViewModel = CreateCredentialViewModel()
        self.shouldPresent(.createCredentialController(createCredentialViewModel))
    }
    
    func handleBackToSignInPressed() {
        self.shouldPresent(.dismiss)
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
                case .backToSignInPressed:
                    self?.handleBackToSignInPressed()
                }
            }) ~ self.disposeBag
    }
}
