//
//  CreateCredentialViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 6/19/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class CreateCredentialViewController: BaseViewController, KeyboardController, LoadingIndicatorController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passwordTextField: MDCPasswordTextField!
    @IBOutlet weak var confirmPasswordTextField: MDCPasswordTextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipMessageLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    
    var passwordController: MDCTextInputControllerOutlined?
    var confirmPasswordController: MDCTextInputControllerOutlined?
    
    var viewModel: CreateCredentialViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension CreateCredentialViewController {
    
    func setUpViews() {
        self.nextButton.primaryStyle()
        self.skipButton.setTitleColor(ColorName.primary.color, for: .normal)
        self.skipButton.customStyle(with: .clear)
        
        self.passwordController = self.passwordTextField.primaryController()
        self.confirmPasswordController = self.confirmPasswordTextField.primaryController()
    }
}

// MARK: - SetUp RxObservers
extension CreateCredentialViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpControlObservers()
        setUpShouldPresentObservers()
        setUpTabSelfToDismissKeyboard()?.disposed(by: self.disposeBag)
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.passwordTextFieldViewModel.bind(with: passwordTextField, controller: passwordController)
        self.viewModel.confirmPasswordTextFieldViewModel.bind(with: confirmPasswordTextField, controller: confirmPasswordController)
        
        self.viewModel.shouldEnbleNext ~> self.nextButton.rx.isEnabled ~ self.disposeBag
    }
    
    func setUpControlObservers() {
        self.nextButton.rx.tap.asObservable()
            .map { _ in CreateCredentialViewModel.Action.nextPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.skipButton.rx.tap.asObservable()
            .map { _ in CreateCredentialViewModel.Action.skipPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .loading(let loading):
                    loading ? self?.showLoading() : self?.dismissLoading()
                case .chooseSecurityMethodController:
                    SereyWallet.shared?.rootViewController.switchToChooseSecurityMethod()
                }
            }) ~ self.disposeBag
    }
}
