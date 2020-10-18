//
//  ActiveBiometryViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 6/20/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import LocalAuthentication

class ActiveBiometryViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case enablePressed
    }
    
    enum ViewToPresent {
        case showAlertDialogController(AlertDialogModel)
        case openUrl(URL)
        case dismiss
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let biometricType: BehaviorRelay<LAContext.BiometricType>
    let iconImage: BehaviorSubject<UIImage?>
    let titleText: BehaviorSubject<String?>
    let descriptionText: BehaviorSubject<String?>
    
    let touchMe: BiometricIDAuth
    
    init(_ biometricType: LAContext.BiometricType) {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.biometricType = .init(value: biometricType)
        self.iconImage = .init(value: nil)
        self.titleText = .init(value: nil)
        self.descriptionText = .init(value: nil)
        
        self.touchMe = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension ActiveBiometryViewModel {
    
    func notifyDataChanged(_ type: LAContext.BiometricType) {
        self.iconImage.onNext(type.iconImage)
        self.titleText.onNext(type.titleText)
        self.descriptionText.onNext(type.descriptionText)
    }
}

// MARK: - Action Handlers
 fileprivate extension ActiveBiometryViewModel {
    
    func handleEnablePressed() {
        touchMe.authenticateUser { errorMessage, requiredSetup in
            if let errorMessage = errorMessage {
                self.handleAuthenticationFailed(message: errorMessage)
            }
            
            // else it means success
            self.handleAuthenticated()
        }
    }
    
    func handleAuthenticated() {
        WalletPreferenceStore.shared.enableBiometry()
        
        let confirmAction = ActionModel(R.string.common.confirm.localized()) {
            self.shouldPresent(.dismiss)
        }
        let alertDialogModel = AlertDialogModel(title: self.biometricType.value.title, message: "You are now can use wallet with your \(self.biometricType.value.title)", actions: [confirmAction])
        self.shouldPresent(.showAlertDialogController(alertDialogModel))
    }
    
    func handleAuthenticationFailed(message: String) {
        let defaultAction = ActionModel(R.string.common.confirm.localized(), style: .cancel)
        let alertDialogModel = AlertDialogModel(title: self.biometricType.value.title, message: message, actions: [defaultAction])
        self.shouldPresent(.showAlertDialogController(alertDialogModel))
    }
}

// MAKR: - SetUp RxObservers
extension ActiveBiometryViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.biometricType.asObservable()
            .subscribe(onNext: { [weak self] type in
                self?.notifyDataChanged(type)
            }) ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .enablePressed:
                    self?.handleEnablePressed()
                }
            }) ~ self.disposeBag
    }
}

// MARK: BiometricType
extension LAContext.BiometricType {
    
    var iconImage: UIImage? {
        switch self {
        case .faceID:
            return R.image.faceIDIcon()
        case .touchID:
            return R.image.fingerPrintIcon()
        default:
            return nil
        }
    }
    
    var titleText: String? {
        switch self {
        case .faceID:
            return "Activate Face ID"
        case .touchID:
            return "Activate FingerPrint ID"
        default:
            return nil
        }
    }
    
    var scanTitle: String? {
        switch self {
        case .faceID:
            return "Scan Your Face to Continue"
        case .touchID:
            return "Scan Finger Print to Continue"
        default:
            return nil
        }
    }
    
    var descriptionText: String? {
        switch self {
        case .faceID:
            return "Face ID make Serey wallet even Secured and faster."
        case .touchID:
            return "Finger Print make Serey wallet even Secured and faster."
        default:
            return nil
        }
    }
}
