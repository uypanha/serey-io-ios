//
//  SignInViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/15/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class SignInViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case signInPressed
        case signUpPressed
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
    let userService: UserService
    
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
            .`do`(onNext: { response in
                AuthData.shared.setAuthData(userToken: response.data.token, username: userName)
            })
            .flatMap { _ in self.userService.fetchProfile(userName) }
            .subscribe(onNext: { [weak self] response in
                self?.shouldPresent(.loading(false))
                response.data.result.save()
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
                }
            }) ~ self.disposeBag
    }
}

