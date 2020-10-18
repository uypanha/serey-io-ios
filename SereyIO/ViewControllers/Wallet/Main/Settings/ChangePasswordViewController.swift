//
//  ChangePasswordViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 8/16/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class ChangePasswordViewController: BaseViewController, KeyboardController, AlertDialogController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var changePasswordLabel: UILabel!
    @IBOutlet weak var currentPasswordField: MDCPasswordTextField!
    @IBOutlet weak var newPasswordField: MDCPasswordTextField!
    @IBOutlet weak var confirmNewPasswordField: MDCPasswordTextField!
    @IBOutlet weak var changeButton: LoadingButton!
    
    var currentPWDController: MDCTextInputControllerOutlined?
    var newPWDController: MDCTextInputControllerOutlined?
    var confirmPWDController: MDCTextInputControllerOutlined?
    
    var viewModel: ChangePasswordViewModel!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setUpRxObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.removeNavigationBarBorder()
        self.navigationController?.setNavigationBarColor(ColorName.primary.color, tintColor: .white)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.containerView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
    }
}

// MARK: - Preparations & Tools
extension ChangePasswordViewController {
    
    func setUpViews() {
        self.headerView.backgroundColor = ColorName.primary.color
        self.currentPWDController = self.currentPasswordField.primaryController()
        self.newPWDController = self.newPasswordField.primaryController()
        self.confirmPWDController = self.confirmNewPasswordField.primaryController()
        
        self.changeButton.primaryStyle()
    }
}

// MARK: - SetUp RxObservers
extension ChangePasswordViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpControlObservers()
        setUpViewToPresentObservers()
        setUpShuoldPresentErrorObservers()
        setUpTabSelfToDismissKeyboard()?.disposed(by: self.disposeBag)
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.currentPasswordTextFieldViewModel.bind(with: self.currentPasswordField, controller: self.currentPWDController)
        self.viewModel.newPasswordTextFieldViewModel.bind(with: self.newPasswordField, controller: self.newPWDController)
        self.viewModel.confirmPasswordTextFieldViewModel.bind(with: self.confirmNewPasswordField, controller: self.confirmPWDController)
        
        self.viewModel.isChangePasswordEnabled
            ~> self.changeButton.rx.isEnabled
            ~ self.disposeBag
    }
    
    func setUpControlObservers() {
        self.changeButton.rx.tap.asObservable()
            .map { ChangePasswordViewModel.Action.changePasswordPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .dismiss:
                    self?.navigationController?.popViewController(animated: true)
                case .loading(let loading):
                    self?.changeButton.isLoading = loading
                case .showAlertDialog(let alertDialogModel):
                    self?.showDialog(alertDialogModel)
                }
            }) ~ self.disposeBag
    }
    
    func setUpShuoldPresentErrorObservers() {
        self.viewModel.shouldPresentError.asObservable()
            .subscribe(onNext: { [weak self] error in
                self?.showDialogError(error)
            }) ~ self.disposeBag
    }
}
