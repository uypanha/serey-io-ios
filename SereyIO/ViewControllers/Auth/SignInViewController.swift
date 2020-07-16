//
//  SignInViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/12/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents
import Then
import RxKeyboard

class SignInViewController: BaseViewController, LoadingIndicatorController, KeyboardController, AlertDialogController {
    
    fileprivate lazy var keyboardDisposeBag = DisposeBag()
    
    @IBOutlet weak var formCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var userNameTextField: MDCTextField!
    @IBOutlet weak var passwordTextField: MDCPasswordTextField!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var dontHaveAccountLabel: UILabel!
    @IBOutlet weak var termServiceTextView: UITextView!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    var userNameController: MDCTextInputControllerOutlined?
    var passwordController: MDCTextInputControllerOutlined?
    
    var viewModel: SignInViewModel!

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
        
        self.signInLabel.text = R.string.auth.signIn.localized()
        self.signInButton.setTitle(R.string.auth.signIn.localized(), for: .normal)
        self.dontHaveAccountLabel.text = R.string.auth.donHaveAccountQuestion.localized()
        self.signUpButton.setTitle(R.string.auth.signUp.localized(), for: .normal)
        self.termServiceTextView.attributedText = self.prepareTermsAndPrivacyString()
    }
}

// MARK: Preparations & Tools
fileprivate extension SignInViewController {
    
    func setUpViews() {
        self.signInButton.customStyle(with: ColorName.buttonBg.color)
        
        self.userNameController = self.userNameTextField.primaryController()
        self.passwordController = self.passwordTextField.primaryController()
        self.termServiceTextView.delegate = self
    }
    
    func prepareTermsAndPrivacyString() -> NSAttributedString? {
        let termsOfServiceText = R.string.common.termService.localized()
        let privacyPolicy = R.string.common.policyAndPrivacy.localized()
        let termsServicePrivacyText = String(format: R.string.common.termsAndPrivacyAgreementMessage.localized(), termsOfServiceText, privacyPolicy)
        
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
extension SignInViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let webViewController = WebViewViewController()
        webViewController.viewModel = WebViewViewModel(withURLToLoad: URL)
        self.present(UINavigationController(rootViewController: webViewController), animated: true, completion: nil)
        return false
    }
}

// MARK: - SetUp RxObservers
fileprivate extension SignInViewController {
    
    func setUpRxObservers() {
        setUpContentObservers()
        setUpControlsEventObservers()
        setUpShouldPresentObservers()
        setUpShouldPresentErrorObservers()
        setUpTabSelfToDismissKeyboard()?.disposed(by: self.disposeBag)
    }
    
    func setUpContentObservers() {
        self.viewModel.userNameTextFieldViewModel.bind(with: self.userNameTextField, controller: self.userNameController)
        self.viewModel.privateKeyOrPwdTextFieldViewModel.bind(with: self.passwordTextField, controller: self.passwordController)
        self.viewModel.shouldEnbleSigIn ~> self.signInButton.rx.isEnabled ~ self.disposeBag
    }
    
    func setUpControlsEventObservers() {
        self.signInButton.rx.tap.asObservable()
            .map { SignInViewModel.Action.signInPressed }
            .bind(to: self.viewModel.didActionSubject)
            ~ self.disposeBag

        self.signUpButton.rx.tap.asObservable()
            .map { SignInViewModel.Action.signUpPressed }
            .bind(to: self.viewModel.didActionSubject)
            ~ self.disposeBag
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch (viewToPresent) {
                case .loading(let loading):
                    loading ? self?.showLoading() : self?.dismissLoading()
                case .signUpViewController:
                    let webViewController = WebViewViewController()
                    webViewController.viewModel = WebViewViewModel(withURLToLoad: Constants.kycURL, title: nil)
                    let navigationViewController = UINavigationController(rootViewController: webViewController)
                        .then { $0.modalPresentationStyle = .fullScreen }
                    self?.show(navigationViewController, sender: nil)
                case .dismiss:
                    self?.dismiss(animated: true, completion: nil)
                }
            }) ~ self.disposeBag
    }
    
    func setUpShouldPresentErrorObservers() {
        self.viewModel.shouldPresentError.asObservable()
            .subscribe(onNext: { [weak self] errorInfo in
                self?.showDialogError(errorInfo, positiveButton: R.string.common.tryAgain.localized(), positiveCompletion: nil)
            }).disposed(by: self.disposeBag)
    }
    
    func setUpRxKeyboardObservers() {
        RxKeyboard.instance.isHidden
            .drive(onNext: { [weak self] isHidden in
                if let _self = self {
                    _self.formCenterConstraint.constant = isHidden ? 0 : 64
                    UIView.animate(withDuration: 0.3, animations: {
                        _self.view.layoutIfNeeded()
                    })
                }
            }).disposed(by: self.keyboardDisposeBag)
        
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
