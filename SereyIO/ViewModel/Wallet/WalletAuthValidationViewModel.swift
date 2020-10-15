//
//  WalletAuthValidationViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 7/25/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class WalletAuthValidationViewModel: BaseViewModel, ShouldPresent {
    
    enum ViewToPresent {
        case signInController
        case signUpWalletController
        case homeWalletController
        case verifyOTPController(VerifyGoogleOTPViewModel)
    }
    
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    override init() {
        self.shouldPresentSubject = .init()
        super.init()
    }
    
    func determineInitialScreen() {
        if let username = AuthData.shared.username {
            if WalletStore.shared.hasPassword(for: username) {
                if WalletPreferenceStore.shared.googleOTPEnabled, let secret = WalletPreferenceStore.shared.googleOTPSecret {
                    let verifyGoogleOTPViewModel = VerifyGoogleOTPViewModel(secret, parent: .verifyToUseWallet)
                    self.shouldPresent(.verifyOTPController(verifyGoogleOTPViewModel))
                } else {
                    self.shouldPresent(.homeWalletController)
                }
            } else {
                self.shouldPresent(.signUpWalletController)
            }
        } else {
            self.shouldPresent(.signInController)
        }
    }
}
