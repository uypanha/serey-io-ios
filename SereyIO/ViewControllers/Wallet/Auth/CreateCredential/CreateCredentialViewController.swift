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

class CreateCredentialViewController: BaseViewController, KeyboardController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passwordTextField: MDCPasswordTextField!
    @IBOutlet weak var confirmPasswordTextField: MDCPasswordTextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
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
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { viewToPresent in
                switch viewToPresent {
                case .chooseSecurityMethodController(let chooseSecurityMethodViewModel):
                    if let chooseSecurityViewController = R.storyboard.auth.chooseSecurityMethodViewController() {
                        chooseSecurityViewController.viewModel = chooseSecurityMethodViewModel
                        self.show(chooseSecurityViewController, sender: nil)
                    }
                }
            }) ~ self.disposeBag
    }
}
