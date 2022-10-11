//
//  ChangePasswordViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 8/16/20.
//  Copyright © 2020 Serey IO. All rights reserved.
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
    
    var viewModel: ChangePasswordViewModel!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setUpRxObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarColor(.color(.primary), tintColor: .white)
        self.navigationController?.removeNavigationBarBorder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.containerView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
    }
}

// MARK: - Preparations & Tools
extension ChangePasswordViewController {
    
    func setUpViews() {
        self.headerView.backgroundColor = .color(.primary)
        self.currentPasswordField.primaryStyle()
        self.newPasswordField.primaryStyle()
        self.confirmNewPasswordField.primaryStyle()
        
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
        self.viewModel.currentPasswordTextFieldViewModel.bind(withMDC: self.currentPasswordField)
        self.viewModel.newPasswordTextFieldViewModel.bind(withMDC: self.newPasswordField)
        self.viewModel.confirmPasswordTextFieldViewModel.bind(withMDC: self.confirmNewPasswordField)
        
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
