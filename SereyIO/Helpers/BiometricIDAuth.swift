//
//  BiometricIDAuth.swift
//  SereyIO
//
//  Created by Panha Uy on 10/16/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import LocalAuthentication

class BiometricIDAuth {
    
    let context = LAContext()
    
    func canEvaluatePolicy() -> Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticateUser(completion: @escaping (String?, Bool) -> Void) { // 1
        //      // 2
        //      guard canEvaluatePolicy() else {
        //        return
        //      }
        
        let type = context.biometricType
        
        // 3
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "We use \(type.title) to authenticate your account.") { (success, evaluateError) in
            // 4
            if success {
                DispatchQueue.main.async {
                    // User authenticated successfully, take appropriate action
                    completion(nil, false)
                }
            } else {
                // TODO: deal with LAError cases
                // 1
                var message: String = ""
                var reqiuredSetUp: Bool = false
                
                switch evaluateError {
                case LAError.authenticationFailed?:
                    message = "There was a problem verifying your identity."
                case LAError.userCancel?:
                    message = "You pressed cancel."
                case LAError.userFallback?:
                    message = "You pressed password."
                default:
                    switch evaluateError {
                    case LAError.biometryNotAvailable?:
                        message = "\(type.title) is not available."
                    case LAError.biometryNotEnrolled?:
                        message = "\(type.title) is not set up. Please go to settings to set up \(type.title)."
                        reqiuredSetUp = true
                    case LAError.biometryLockout?:
                        message = "\(type.title) is locked."
                    default:
                        message = "\(type.title) may not be configured"
                        reqiuredSetUp = true
                    }
                }
                
                // 4
                DispatchQueue.main.async {
                    completion(message, reqiuredSetUp)
                }
            }
        }
    }
    
    func getPwSecAccessControl() -> SecAccessControl {
        var access: SecAccessControl?
        var error: Unmanaged<CFError>?
        
        access = SecAccessControlCreateWithFlags(nil,
                                                 kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                 .applicationPassword,
                                                 &error)
        precondition(access != nil, "SecAccessControlCreateWithFlags failed")
        return access!
    }
}
