//
//  ChangePasswordViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 9/26/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class ChangePasswordViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case changePasswordPressed
    }
    
    enum ViewToPresent {
        case loading(Bool)
        case dismiss
        case showAlertDialog(AlertDialogModel)
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let currentPasswordTextFieldViewModel: TextFieldViewModel
    let newPasswordTextFieldViewModel: TextFieldViewModel
    let confirmPasswordTextFieldViewModel: TextFieldViewModel
    
    let isChangePasswordEnabled: BehaviorSubject<Bool>
    
    let userService: UserService
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.currentPasswordTextFieldViewModel = .textFieldWith(title: "Current Password", errorMessage: "", validation: .notEmpty)
        self.newPasswordTextFieldViewModel = .textFieldWith(title: "New Password", errorMessage: "", validation: .strongPassword)
        self.confirmPasswordTextFieldViewModel = .textFieldWith(title: "Confirm New Password", errorMessage: "", validation: .strongPassword)
        
        self.isChangePasswordEnabled = .init(value: false)
        self.userService = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension ChangePasswordViewModel {
    
    private func requestChangePassword(_ current: String, _ new: String) {
        self.shouldPresent(.loading(true))
        self.userService.changePassword(current, new)
            .subscribe(onNext: { [weak self] data in
                self?.shouldPresent(.loading(false))
                self?.handleChangePasswordSuccess()
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension ChangePasswordViewModel {
    
    func validateForm() -> Bool {
        return self.currentPasswordTextFieldViewModel.validate()
            && self.newPasswordTextFieldViewModel.validate()
            && self.confirmPasswordTextFieldViewModel.validate(match: self.newPasswordTextFieldViewModel.value)
    }
    
    func areFieldsFilled() -> Bool {
        return !(self.currentPasswordTextFieldViewModel.value ?? "").isEmpty &&
            !(self.newPasswordTextFieldViewModel.value ?? "").isEmpty &&
            !(self.confirmPasswordTextFieldViewModel.value ?? "").isEmpty
    }
}

// MARK: - Action Handlers
fileprivate extension ChangePasswordViewModel {
    
    func handleChangePasswordPressed() {
        if self.validateForm() {
            let current = self.currentPasswordTextFieldViewModel.value ?? ""
            let new = self.newPasswordTextFieldViewModel.value ?? ""
            self.requestChangePassword(current, new)
        }
    }
    
    func handleChangePasswordSuccess() {
        let confirmAction = ActionModel(R.string.common.confirm.localized(), style: .default) {
            self.shouldPresent(.dismiss)
        }
        let alertDialogModel = AlertDialogModel(title: "Change Password", message: "", actions: [confirmAction])
        self.shouldPresent(.showAlertDialog(alertDialogModel))
    }
}

// MARK: - SetUp RxObservers
extension ChangePasswordViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObsevers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObsevers() {
        self.currentPasswordTextFieldViewModel.textFieldText
            .map { [unowned self] _ in self.areFieldsFilled() }
            ~> self.isChangePasswordEnabled
            ~ self.disposeBag
        
        self.newPasswordTextFieldViewModel.textFieldText
            .map { [unowned self] _ in self.areFieldsFilled() }
            ~> self.isChangePasswordEnabled
            ~ self.disposeBag
        
        self.confirmPasswordTextFieldViewModel.textFieldText
            .map { [unowned self] _ in self.areFieldsFilled() }
            ~> self.isChangePasswordEnabled
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .changePasswordPressed:
                    self?.handleChangePasswordPressed()
                }
            }) ~ self.disposeBag
    }
}
