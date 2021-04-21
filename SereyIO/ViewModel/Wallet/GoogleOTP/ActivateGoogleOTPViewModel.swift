//
//  ActivateGoogleOTPViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 6/22/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import SwiftOTP
import Steem

class ActivateGoogleOTPViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case activatePressed
        case agreementChecked(checked: Bool)
        case codeVerified
    }
    
    enum ViewToPresent {
        case verifyGoogleOTPController(VerifyGoogleOTPViewModel)
        case showAlertDialog(AlertDialogModel)
        case walletController
        case dismiss
    }
    
    enum ParentController {
        case signUp
        case settings
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let parent: BehaviorRelay<ParentController>
    let totpKey: BehaviorRelay<String?>
    let isActivateEnabled: BehaviorRelay<Bool>
    let qrImage: BehaviorSubject<UIImage?>
    
    init(_ parent: ParentController) {
        self.parent = .init(value: parent)
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.isActivateEnabled = .init(value: false)
        self.totpKey = .init(value: AuthData.shared.username?.base32EncodedString)
        self.qrImage = .init(value: nil)
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension ActivateGoogleOTPViewModel {
    
    func prepareQrCodeImage(_ key: String) {
        DispatchQueue.main.async {
            self.qrImage.onNext(UtilitiesHelper.generateQRCode(from: self.prepareTotpUrl(from: key)))
        }
    }
    
    func prepareTotpUrl(from key: String) -> String {
        return "otpauth://totp/SereyWalletAuthenticator?secret=\(key)&issuer=SereyWallet"
    }
}

// MARK: - Action Handlers
fileprivate extension ActivateGoogleOTPViewModel {
    
    func handleActivatePressed() {
        let verifyGoogleOTPViewModel = VerifyGoogleOTPViewModel(self.totpKey.value ?? "", parent: .activateOTP)
        
        verifyGoogleOTPViewModel.otpCodeVerified.asObservable()
            .map { Action.codeVerified }
            ~> self.didActionSubject
            ~ verifyGoogleOTPViewModel.disposeBag
        
        self.shouldPresent(.verifyGoogleOTPController(verifyGoogleOTPViewModel))
    }
    
    func handleOTPVerified() {
        if let secret = self.totpKey.value {
            WalletPreferenceStore.shared.enableGoogleOTP(secret)
            
            let confirmAction = ActionModel(R.string.common.confirm.localized()) {
                if self.parent.value == .signUp {
                    self.shouldPresent(.walletController)
                } else {
                    self.shouldPresent(.dismiss)
                }
            }
            
            let alertDialogModel = AlertDialogModel(title: "Google OTP", message: "You've successfully enabled Google OTP.", actions: [confirmAction])
            self.shouldPresent(.showAlertDialog(alertDialogModel))
        }
    }
}

// MARK: - Set RxObservers
extension ActivateGoogleOTPViewModel {
 
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.totpKey.asObservable()
            .subscribe(onNext: { [weak self] key in
                self?.prepareQrCodeImage(key ?? "")
            }) ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .activatePressed:
                    self?.handleActivatePressed()
                case .agreementChecked(let checked):
                    self?.isActivateEnabled.accept(checked)
                case .codeVerified:
                    self?.handleOTPVerified()
                }
            }) ~ self.disposeBag
    }
}
