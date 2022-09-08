//
//  SignInViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/15/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class SignInViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case signInPressed
        case signUpPressed
        case editingChanged
    }
    
    enum ViewToPresent {
        case signUpViewController
        case loading(Bool)
        case dismiss
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<SignInViewModel.Action>()
    
    // output
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    
    let userNameTextFieldViewModel: TextFieldViewModel
    let privateKeyOrPwdTextFieldViewModel: TextFieldViewModel
    let shouldEnbleSigIn: BehaviorSubject<Bool>
    
    let authService: AuthService
    var userService: UserService
    
    override init() {
        self.userNameTextFieldViewModel = TextFieldViewModel.userNameTextFieldViewModel()
        self.privateKeyOrPwdTextFieldViewModel = TextFieldViewModel.privateKeyOrPwdTextFieldViewModel()
        self.shouldEnbleSigIn = BehaviorSubject(value: false)
        self.authService = AuthService()
        self.userService = UserService()
        super.init()
        
        setUpRxObservers()
    }
}

// MAKR: - Networks
extension SignInViewModel {
    
    fileprivate func signIn(_ userName: String, _ privateKeyOrPwd: String) {
        self.shouldPresent(.loading(true))
        self.authService.signIn(userName, privateKeyOrPwd)
            .flatMap { response in
                return self.userService.fetchProfile(userName)
                .asObservable()
                .map { (response, $0) }
            }
            .subscribe(onNext: { [weak self] data in
                self?.shouldPresent(.loading(false))
                data.1.data.result.save()
                AuthData.shared.setAuthData(userToken: data.0.data.token, username: userName)
                self?.shouldPresent(.dismiss)
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }).disposed(by: self.disposeBag)
    }
}

// MARK: - Preparations & Tools
extension SignInViewModel {
    
    fileprivate func validateForm() -> Bool {
        return self.userNameTextFieldViewModel.validate()
            && self.privateKeyOrPwdTextFieldViewModel.validate()
    }
    
    fileprivate func validateTyping() -> Bool {
        return self.userNameTextFieldViewModel.validate(true)
            && self.privateKeyOrPwdTextFieldViewModel.validate(true)
    }
}

// MAR: - Action Handlers
fileprivate extension SignInViewModel {
    
    func areFieldsFilled() -> Bool {
        return !(self.userNameTextFieldViewModel.value ?? "").isEmpty &&
            !(self.privateKeyOrPwdTextFieldViewModel.value ?? "").isEmpty
    }
    
    func handleSignInPressed() {
        if self.validateForm() {
            let userName = self.userNameTextFieldViewModel.textFieldText.value ?? ""
            let privateKeyOrPwd = self.privateKeyOrPwdTextFieldViewModel.textFieldText.value ?? ""
            
            self.signIn(userName, privateKeyOrPwd)
        }
    }
    
    func handleSignUpPressed() {
        self.shouldPresent(.signUpViewController)
    }
}

// MARK: - SetUp RxObservers
fileprivate extension SignInViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.userNameTextFieldViewModel.textFieldText
            .map { [unowned self] _ in self.areFieldsFilled() }
            ~> self.shouldEnbleSigIn
            ~ self.disposeBag
        
        self.privateKeyOrPwdTextFieldViewModel.textFieldText
            .map { [unowned self] _ in self.areFieldsFilled() }
            ~> self.shouldEnbleSigIn
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .signInPressed:
                    self?.handleSignInPressed()
                case .signUpPressed:
                    self?.handleSignUpPressed()
                case .editingChanged:
                    _ = self?.validateTyping()
                }
            }) ~ self.disposeBag
    }
}

