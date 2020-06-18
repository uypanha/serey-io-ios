//
//  LAContext.swift
//  SereyIO
//
//  Created by Panha Uy on 6/16/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import LocalAuthentication

extension LAContext {
    
    enum BiometricType {
        case touchID
        case faceID
        case none
    }
    
    var biometricType: BiometricType {
        let context = LAContext()
        if #available(iOS 11, *) {
            var error: NSError?
            let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            
            if error?.code == LAError.Code.touchIDNotAvailable.rawValue {
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
