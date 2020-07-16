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

class ActiveBiometryViewModel: BaseViewModel {
    
    let biometricType: BehaviorRelay<LAContext.BiometricType>
    let iconImage: BehaviorSubject<UIImage?>
    let titleText: BehaviorSubject<String?>
    let descriptionText: BehaviorSubject<String?>
    
    init(_ biometricType: LAContext.BiometricType) {
        self.biometricType = .init(value: biometricType)
        self.iconImage = .init(value: nil)
        self.titleText = .init(value: nil)
        self.descriptionText = .init(value: nil)
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

// MAKR: - SetUp RxObservers
extension ActiveBiometryViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.biometricType.asObservable()
            .subscribe(onNext: { [weak self] type in
                self?.notifyDataChanged(type)
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
