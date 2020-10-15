//
//  ActivateGoogleOTPViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 6/21/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents
import RxKeyboard

class ActivateGoogleOTPViewController: BaseViewController, KeyboardController {
    
    fileprivate lazy var keyboardDisposeBag = DisposeBag()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var qrContainerView: CardView!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var manualCopyKeyButton: UIButton!
    @IBOutlet weak var verificationCodeTextField: MDCPasswordTextField!
    @IBOutlet weak var verifyButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var verificationCodeController: MDCTextInputControllerOutlined?
    
    var viewModel: ActivateGoogleOTPViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setUpRxKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.keyboardDisposeBag = DisposeBag()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.verifyButton.setTitle(R.string.auth.verifyAndActivate.localized(), for: .normal)
        self.titleLabel.text = R.string.googleOTP.activateGoogleAuthenticationApp.localized()
        self.descriptionLabel.text = R.string.googleOTP.activateGoogleAuthenticationAppMessage.localized()
        self.manualCopyKeyButton.setTitle(R.string.googleOTP.manualKey.localized(), for: .normal)
    }
}

// MARK: - Preparations & Tools
extension ActivateGoogleOTPViewController {
    
    func setUpViews() {
        self.qrContainerView.borderColor = ColorName.border.color
        self.manualCopyKeyButton.primaryStyle()
        self.verifyButton.primaryStyle()
        
        self.verificationCodeController = self.verificationCodeTextField.primaryController()
        self.verificationCodeTextField.keyboardType = .numberPad
        self.verificationCodeTextField.delegate = self
    }
}

// MARK: - UITextFieldDelegate
extension ActivateGoogleOTPViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 6
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: String = currentString.replacingCharacters(in: range, with: string)
        return newString.count <= maxLength
    }
}

// MARK: - SetUp RxObservers
extension ActivateGoogleOTPViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpControlObservers()
        setUpShouldPresentObservers()
        setUpTabSelfToDismissKeyboard()?.disposed(by: self.disposeBag)
    }
    
    func setUpContentChangedObservers() {
        self.disposeBag ~ [
            self.viewModel.qrImage ~> self.qrImageView.rx.image
        ]
    }
    
    func setUpControlObservers() {
//        self.verifyButton.rx.tap.asObservable()
//            .map { ActivateGoogleOTPViewModel.Action.verifyPressed }
//            ~> self.viewModel.didActionSubject
//            ~ self.disposeBag
    }
    
    func setUpShouldPresentObservers() {
//        self.viewModel.shouldPresent.asObservable()
//            .subscribe(onNext: { [weak self] viewToPresent in
//                switch viewToPresent {
////                case .loading(let loading):
////                    self?.manualCopyKeyButton.isHidden = loading
////                case .walletViewController:
////                    SereyWallet.shared?.rootViewController.switchToMainScreen()
//                case .verifyGoogleOTPController:
//                    break
//                }
//            }) ~ self.disposeBag
    }
    
    func setUpRxKeyboardObservers() {
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardHeight in
                if let _self = self {
                    _self.bottomConstraint.constant = keyboardHeight
                    UIView.animate(withDuration: 0.3, animations: {
                        _self.view.layoutIfNeeded()
                    })
                }
            }).disposed(by: self.keyboardDisposeBag)
    }
}
