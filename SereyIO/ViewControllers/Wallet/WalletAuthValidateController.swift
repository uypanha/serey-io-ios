//
//  WalletAuthValidateController.swift
//  SereyIO
//
//  Created by Panha Uy on 7/25/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import UIKit

class WalletAuthValidateController: BaseViewController {
    
    lazy var viewModel: WalletAuthValidationViewModel = WalletAuthValidationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        setRxObservers()
        self.viewModel.determineInitialScreen()
    }
}

// MARK: - SetUp RxObservers
extension WalletAuthValidateController {
    
    func setRxObservers() {
        setUpViewToPresentObservers()
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { viewToPresent in
                switch viewToPresent {
                case .signUpWalletController:
                    SereyWallet.shared?.rootViewController.switchToSignUpWallet()
                case .homeWalletController:
                    SereyWallet.shared?.rootViewController.switchToMainScreen()
                case .signInController:
                    SereyWallet.shared?.rootViewController.switchToSignInScreen()
                case .verifyOTPController(let verifyGoogleOTPViewModel):
                    SereyWallet.shared?.rootViewController.switchToVerifyGoogleOTPScreen(viewModel: verifyGoogleOTPViewModel)
                case .verifyBiometryController:
                    SereyWallet.shared?.rootViewController.switchToVerifyBiometryScreen()
                }
            }) ~ self.disposeBag
    }
}
