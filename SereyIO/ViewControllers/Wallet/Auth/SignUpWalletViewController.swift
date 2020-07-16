//
//  SignUpWalletViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 6/17/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents
import RxKeyboard

class SignUpWalletViewController: BaseViewController, KeyboardController {
    
    fileprivate lazy var keyboardDisposeBag = DisposeBag()
    
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var usernameTextField: MDCTextField!
    @IBOutlet weak var ownerKeyTextField: MDCPasswordTextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var signUpMessageLabel: UILabel!
    @IBOutlet weak var backToSignInButton: UIButton!
    
    var userNameController: MDCTextInputControllerOutlined?
    var ownerKeyController: MDCTextInputControllerOutlined?
    
    var viewModel: SignUpWalletViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension SignUpWalletViewController {
    
    func setUpViews() {
        self.userNameController = self.usernameTextField.primaryController()
        self.ownerKeyController = self.ownerKeyTextField.primaryController()
        self.nextButton.primaryStyle()
    }
}

// MARK: - SetUp RxObservers
extension SignUpWalletViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpShouldPresentObservers()
        setUpControlsObservers()
        setUpTabSelfToDismissKeyboard()?.disposed(by: self.disposeBag)
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.userNameTextFieldViewModel.bind(with: usernameTextField, controller: userNameController)
        self.viewModel.ownerKeyTextFieldViewModel.bind(with: ownerKeyTextField, controller: ownerKeyController)
        
        self.viewModel.shouldEnbleSignUp ~> self.nextButton.rx.isEnabled ~ self.disposeBag
    }
    
    func setUpControlsObservers() {
        self.nextButton.rx.tap.asObservable()
            .map { SignUpWalletViewModel.Action.signUpPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.backToSignInButton.rx.tap.asObservable()
            .map { SignUpWalletViewModel.Action.backToSignInPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [unowned self] viewToPresent in
                switch viewToPresent {
                case .createCredentialController(let createCredentialViewModel):
                    if let createCredentialController = R.storyboard.auth.createCredentialViewController() {
                        createCredentialController.viewModel = createCredentialViewModel
                        self.show(createCredentialController, sender: nil)
                    }
                case .dismiss:
                    self.navigationController?.popViewController(animated: true)
                }
            }) ~ self.disposeBag
    }
}
