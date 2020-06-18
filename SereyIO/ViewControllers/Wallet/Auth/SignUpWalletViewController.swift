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
        setUpTabSelfToDismissKeyboard()?.disposed(by: self.disposeBag)
    }
}
