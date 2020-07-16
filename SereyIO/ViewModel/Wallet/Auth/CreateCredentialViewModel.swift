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
    }
    
    enum ViewToPresent {
        case chooseSecurityMethodController(ChooseSecurityMethodViewModel)
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let shouldEnbleNext: BehaviorSubject<Bool>
    
    let passwordTextFieldViewModel: TextFieldViewModel
    let confirmPasswordTextFieldViewModel: TextFieldViewModel
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.passwordTextFieldViewModel = .textFieldWith(title: "Password", errorMessage: "Please make sure your password is a correct format.", validation: .strongPassword)
        self.confirmPasswordTextFieldViewModel = .textFieldWith(title: "Confirm Password", errorMessage: "Please make sure your passwords match.", validation: .strongPassword)
        self.shouldEnbleNext = .init(value: false)
        super.init()
        
        setUpRxObservers()
    }
}


// MARK: - Preparations & Tools
extension CreateCredentialViewModel {
    
    func validateForm() -> Bool {
        return self.passwordTextFieldViewModel.validate()
            && self.confirmPasswordTextFieldViewModel.validate(with: self.passwordTextFieldViewModel.value)
    }
    
    func areFieldsFilled() -> Bool {
        return !(self.passwordTextFieldViewModel.value ?? "").isEmpty &&
            !(self.confirmPasswordTextFieldViewModel.value ?? "").isEmpty
    }
}

// MARK: - Action Handlers
fileprivate extension CreateCredentialViewModel {
    
    func handleNextPressed() {
//        if self.validateForm() {}
        let chooseSecurityMethodViewModel = ChooseSecurityMethodViewModel()
        self.shouldPresent(.chooseSecurityMethodController(chooseSecurityMethodViewModel))
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
                }
            }) ~ self.disposeBag
    }
}
