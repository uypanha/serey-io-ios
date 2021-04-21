//
//  WalletRootViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 6/27/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

class WalletRootViewController: BaseRootViewController {
    
    var deeplink: DeeplinkType? {
        didSet {
            handleDeeplink()
        }
    }
    
    init() {
        super.init(CloseableNavigationController(rootViewController: WalletAuthValidateController()))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Switching Screens
extension WalletRootViewController {
    
    func switchToVerifyGoogleOTPScreen(viewModel: VerifyGoogleOTPViewModel, fadeAnimation: Bool = true) {
        let verifyOTPViewController = R.storyboard.googleOTP.verifyGoogleOTPViewController()!
        verifyOTPViewController.viewModel = viewModel
        let closableViewController = CloseableNavigationController(rootViewController: verifyOTPViewController)
        if fadeAnimation {
            self.animateFadeTransition(to: closableViewController)
        } else {
            self.animateSlideToTopTransition(to: closableViewController)
        }
    }
    
    func switchToVerifyBiometryScreen(_ fadeAnimation: Bool = true) {
        let verifyBiometryViewController = R.storyboard.biometry.verifyBiometryViewController()!
        verifyBiometryViewController.viewModel = VerifyBiometryViewModel()
        if fadeAnimation {
            self.animateFadeTransition(to: verifyBiometryViewController)
        } else {
            self.animateSlideToTopTransition(to: verifyBiometryViewController)
        }
    }
    
    func switchToSignInScreen(fadeAnimation: Bool = true) {
        let mainWalletViewController = R.storyboard.auth.signInViewController()!
        mainWalletViewController.viewModel = SignInViewModel()
        let closableViewController = CloseableNavigationController(rootViewController: mainWalletViewController)
        if fadeAnimation {
            self.animateFadeTransition(to: closableViewController)
        } else {
            self.animateSlideToTopTransition(to: closableViewController)
        }
    }
    
    func switchToMainScreen(fadeAnimation: Bool = true) {
        let mainWalletViewController = R.storyboard.wallet.walletViewController()!
        mainWalletViewController.viewModel = WalletViewModel()
        let closableViewController = CloseableNavigationController(rootViewController: mainWalletViewController)
        if fadeAnimation {
            self.animateFadeTransition(to: closableViewController) { [weak self] in
                self?.handleDeeplink()
            }
        } else {
            self.animateSlideToTopTransition(to: closableViewController) { [weak self] in
                self?.handleDeeplink()
            }
        }
    }
    
    func switchToSignUpWallet(fadeAnimation: Bool = true) {
        let signUpWalletViewController = R.storyboard.auth.signUpWalletViewController()!
        signUpWalletViewController.viewModel = SignUpWalletViewModel()
        let closableViewController = CloseableNavigationController(rootViewController: signUpWalletViewController)
        if fadeAnimation {
            self.animateFadeTransition(to: closableViewController) { [weak self] in
                self?.handleDeeplink()
            }
        } else {
            self.animateSlideToTopTransition(to: closableViewController) { [weak self] in
                self?.handleDeeplink()
            }
        }
    }
    
    func switchToCreateCredential(fadeAnimation: Bool = true, viewModel: CreateCredentialViewModel) {
        let createCredentialViewController = R.storyboard.auth.createCredentialViewController()!
        createCredentialViewController.viewModel = viewModel
        let closableViewController = CloseableNavigationController(rootViewController: createCredentialViewController)
        if fadeAnimation {
            self.animateFadeTransition(to: closableViewController) { [weak self] in
                self?.handleDeeplink()
            }
        } else {
            self.animateSlideToTopTransition(to: closableViewController) { [weak self] in
                self?.handleDeeplink()
            }
        }
    }
    
    func switchToChooseSecurityMethod(fadeAnimation: Bool = true) {
        let chooseSecurityMethodViewController = R.storyboard.auth.chooseSecurityMethodViewController()!
        chooseSecurityMethodViewController.viewModel = ChooseSecurityMethodViewModel()
        let closableViewController = CloseableNavigationController(rootViewController: chooseSecurityMethodViewController)
        if fadeAnimation {
            self.animateFadeTransition(to: closableViewController) { [weak self] in
                self?.handleDeeplink()
            }
        } else {
            self.animateSlideToTopTransition(to: closableViewController) { [weak self] in
                self?.handleDeeplink()
            }
        }
    }
}

// MARK: - Preparations & Tools
extension WalletRootViewController {
    
    private func handleDeeplink() {
        if let deeplink = self.deeplink {
            switch deeplink {
            case .browser(let url):
                let webViewViewController = WebViewViewController()
                webViewViewController.viewModel = WebViewViewModel(withURLToLoad: url, title: "")
                self.present(UINavigationController(rootViewController: webViewViewController), animated: true, completion: nil)
                
                // reset the deeplink back no nil, so it will not be triggered more than once
                self.deeplink = nil
            default:
//                if let mainNavigationController = currentViewController as? MainNavigationViewController {
//
//                    mainNavigationController.handleDeeplink(deeplink)
//
//                    // reset the deeplink back no nil, so it will not be triggered more than once
//                    self.deeplink = nil
//                }
                break
            }
        }
    }
}
