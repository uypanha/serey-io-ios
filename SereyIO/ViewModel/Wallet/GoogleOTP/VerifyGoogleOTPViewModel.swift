//
//  VerifyGoogleOTPViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 10/14/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import SwiftOTP

class VerifyGoogleOTPViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case confirmPressed
    }
    
    enum ViewToPresent {
        case dismiss
        case walletController
    }
    
    enum ParentController {
        case activateOTP
        case verifyToUseWallet
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let parent: ParentController
    let secret: BehaviorRelay<String>
    let pinCodeTextFieldViewModel: TextFieldViewModel
    
    let messageText: BehaviorSubject<String?>
    let verifyButtonTitle: BehaviorSubject<String?>
    
    let otpCodeVerified: PublishSubject<Void>
    
    init(_ secret: String, parent: ParentController) {
        self.parent = parent
        self.secret = .init(value: secret)
        self.pinCodeTextFieldViewModel = .textFieldWith(title: "", errorMessage: nil, validation: .min(6))
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        self.messageText = .init(value: nil)
        self.verifyButtonTitle = .init(value: nil)
        
        self.otpCodeVerified = .init()
        super.init()
        
        setUpRxObservers()
        prepareTexts()
    }
}

// MARK: - Preparations & Tools
extension VerifyGoogleOTPViewModel {
    
    func prepareTexts() {
        let message = self.parent == .activateOTP ? "Just incase of missing OTP generator app, please re-activate your wallet app to reset your two factor authenticator." : "Enter OTP code from your Google Authenticator app to continue using the Wallet."
        self.messageText.onNext(message)
        
        let verifyTitle = self.parent == .activateOTP ? "Confirm OTP" : "Verify OTP"
        self.verifyButtonTitle.onNext(verifyTitle)
    }
    
    func verifyCode(_ code: String) {
        if let data = base32DecodeToData(self.secret.value) {
            if let otp = TOTP(secret: data)?.generate(time: Date()) {
                if otp.compare(code).rawValue == 0 {
                    if self.parent == .activateOTP {
                        self.otpCodeVerified.onNext(())
                        self.shouldPresent(.dismiss)
                    } else {
                        self.shouldPresent(.walletController)
                    }
                }
            }
        }
    }
    
    func validate() -> Bool {
        return self.pinCodeTextFieldViewModel.validate()
    }
}

// MARK: - Action Handlers
fileprivate extension VerifyGoogleOTPViewModel {
    
    func handleConfirmPressed() {
        if self.validate() {
            let code = self.pinCodeTextFieldViewModel.value ?? ""
            self.verifyCode(code)
        }
    }
}

// MARK: - SetUp RxObservers
extension VerifyGoogleOTPViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .confirmPressed:
                    self?.handleConfirmPressed()
                }
            }) ~ self.disposeBag
    }
}
