//
//  SignUpWalletViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 6/17/20.
//  Copyright © 2020 Serey IO. All rights reserved.
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
    @IBOutlet weak var usernameTextField: MDCOutlinedTextField!
    @IBOutlet weak var ownerKeyTextField: MDCPasswordTextField!
    @IBOutlet weak var nextButton: LoadingButton!
    @IBOutlet weak var signUpMessageLabel: UITextView!
    
    var viewModel: SignUpWalletViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.signUpLabel.text = R.string.wallet.signUpWallet.localized()
        self.signUpMessageLabel.attributedText = self.prepareTermsAndPrivacyString()
    }
}

// MARK: - Preparations & Tools
extension SignUpWalletViewController {
    
    func setUpViews() {
        self.usernameTextField.primaryStyle()
        self.ownerKeyTextField.primaryStyle()
        
        self.usernameTextField.textColor = .lightGray
        self.nextButton.primaryStyle()
        self.signUpMessageLabel.delegate = self
        self.usernameTextField.isEnabled = false
    }
    
    func prepareTermsAndPrivacyString() -> NSAttributedString? {
        let termsOfServiceText = R.string.common.termService.localized()
        let privacyPolicy = R.string.common.policyAndPrivacy.localized()
        let termsServicePrivacyText = String(format: R.string.wallet.termsAndPrivacyAgreementMessage.localized(), termsOfServiceText, privacyPolicy)
        
        let attributedString = NSMutableAttributedString(string: termsServicePrivacyText)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineHeightMultiple = 1.2
        paragraphStyle.alignment = .center
        
        let commonAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.8),
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        attributedString.addAttributes(commonAttributes, range: NSRange(location: 0, length: attributedString.length))
        
        let termsRange = (termsServicePrivacyText as NSString).range(of: termsOfServiceText)
        let privacyRange = (termsServicePrivacyText as NSString).range(of: privacyPolicy)
        
        if let termsLink = Constants.termAndConditionsUrl, let policyLink = Constants.privacyAndPolicyUrl {
            let linkAttributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.link: termsLink
            ]
            
            let policyAttribute: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.link: policyLink
            ]
            attributedString.addAttributes(linkAttributes, range: termsRange)
            attributedString.addAttributes(policyAttribute, range: privacyRange)
        }
        
        return attributedString
    }
}

// MARK: - UITextViewDelegate
extension SignUpWalletViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let webViewController = WebViewViewController()
        webViewController.viewModel = WebViewViewModel(withURLToLoad: URL)
        self.present(UINavigationController(rootViewController: webViewController), animated: true, completion: nil)
        return false
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
        self.viewModel.userNameTextFieldViewModel.bind(withMDC: usernameTextField)
        self.viewModel.ownerKeyTextFieldViewModel.bind(withMDC: ownerKeyTextField)
        
        self.viewModel.shouldEnbleSignUp ~> self.nextButton.rx.isEnabled ~ self.disposeBag
    }
    
    func setUpControlsObservers() {
        self.nextButton.rx.tap.asObservable()
            .map { SignUpWalletViewModel.Action.signUpPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [unowned self] viewToPresent in
                switch viewToPresent {
                case .createCredentialViewController(let createCredentialViewModel):
                    SereyWallet.shared?.rootViewController.switchToCreateCredential(viewModel: createCredentialViewModel)
                case .dismiss:
                    self.navigationController?.popViewController(animated: true)
                case .loading(let loading):
                    self.ownerKeyTextField.isEnabled = !loading
                    self.nextButton.isLoading = loading
                }
            }) ~ self.disposeBag
    }
}
