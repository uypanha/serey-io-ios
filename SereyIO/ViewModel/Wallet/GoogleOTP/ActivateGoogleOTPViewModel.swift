//
//  ActivateGoogleOTPViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 6/22/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import SwiftOTP
import Steem

class ActivateGoogleOTPViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case verifyPressed
    }
    
    enum ViewToPresent {
        case loading(Bool)
        case walletViewController
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let totpKey: BehaviorRelay<String?>
    let qrImage: BehaviorSubject<UIImage?>
    
    let verificationCodeTextFieldViewModel: TextFieldViewModel
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.totpKey = .init(value: "P5Kac8enBjVAnRGYMY1LK8xJu9AhZ6u3GWua57gytSebG4SQMgvb")
        self.qrImage = .init(value: nil)
        
        self.verificationCodeTextFieldViewModel = .textFieldWith(title: R.string.auth.verificationCode.localized(), errorMessage: nil, validation: .min(6))
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension ActivateGoogleOTPViewModel {
    
    func verifyCode(_ code: String) {
        self.shouldPresent(.loading(true))
        if let data = base32DecodeToData(self.totpKey.value ?? "") {
            if let otp = TOTP(secret: data)?.generate(time: Date()) {
                if otp.compare(code).rawValue == 0 {
                    self.shouldPresent(.walletViewController)
                }
            }
        }
        self.shouldPresent(.loading(false))
    }
    
    func prepareQrCodeImage(_ key: String) {
        DispatchQueue.main.async {
            self.qrImage.onNext(UtilitiesHelper.generateQRCode(from: self.prepareTotpUrl(from: key)))
        }
    }
    
    func prepareTotpUrl(from key: String) -> String {
        let privateKeyString = key
        _ = privateKeyString.dropFirst()
        let privateKey = PrivateKey(privateKeyString)
        return "otpauth://totp/SereyWallet:iOS?secret=\(privateKey?.createPublic().address ?? key)&issuer=SereyWallet"
    }
    
    func validate() -> Bool {
        return self.verificationCodeTextFieldViewModel.validate()
    }
}

// MARK: - Action Handlers
fileprivate extension ActivateGoogleOTPViewModel {
    
    func handleVerifyPressed() {
        if self.validate() {
            let code = self.verificationCodeTextFieldViewModel.value
            self.verifyCode(code ?? "")
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
        
        self.verificationCodeTextFieldViewModel.textFieldText.asObservable()
            .filter { _ in self.validate() }
            .subscribe(onNext: { [weak self] code in
                self?.verifyCode(code ?? "")
            }) ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .verifyPressed:
                    self?.handleVerifyPressed()
                }
            }) ~ self.disposeBag
    }
}
