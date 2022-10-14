//
//  LAContext.swift
//  SereyIO
//
//  Created by Panha Uy on 6/16/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import LocalAuthentication

extension LAContext {
    
    enum BiometricType {
        case touchID
        case faceID
        case none
        
        var title: String {
            switch self {
            case .touchID:
                return "Touch ID"
            case .faceID:
                return "Face ID"
            default:
                return ""
            }
        }
        
        var settingTitle: String {
            switch self {
            case .touchID:
                return "Fingerprint"
            case .faceID:
                return "Face ID"
            default:
                return ""
            }
        }
    }
    
    var biometricType: BiometricType {
        let context = LAContext()
        if #available(iOS 11, *) {
            var error: NSError?
            let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            
            if error?.code == LAError.Code.biometryNotAvailable.rawValue {
                return .none
            }
            
            switch(context.biometryType) {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            }
        } else {
            return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
        }
    }
}
