//
//  VerifyBiometryViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 10/17/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import LocalAuthentication

class VerifyBiometryViewModel: BaseViewModel, ShouldPresent {
    
    enum ViewToPresent {
        case walletController
        case alertDialogController(AlertDialogModel)
        case dismiss
    }
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let biometricType: BehaviorRelay<LAContext.BiometricType>
    let iconImage: BehaviorSubject<UIImage?>
    let titleText: BehaviorSubject<String?>
    
    let touchMe: BiometricIDAuth
    
    override init() {
        let type = LAContext().biometricType
        self.biometricType = .init(value: type)
        self.iconImage = .init(value: type.iconImage)
        self.titleText = .init(value: type.scanTitle)
        
        self.shouldPresentSubject = .init()
        self.touchMe = .init()
        super.init()
    }
}

// MARK: - Preparations & Tools
extension VerifyBiometryViewModel {
    
    func verify() {
        self.touchMe.authenticateUser { (message, requiredSetUp) in
            if let message = message {
                self.handleScanError(message: message)
            } else {
                self.shouldPresent(.walletController)
            }
        }
    }
    
    private func handleScanError(message: String) {
        let confirmAction = ActionModel(R.string.common.confirm.localized()) {
            self.shouldPresent(.dismiss)
        }
        let alertDialogModel = AlertDialogModel(title: self.biometricType.value.title, message: message, actions: [confirmAction])
        self.shouldPresent(.alertDialogController(alertDialogModel))
    }
}
