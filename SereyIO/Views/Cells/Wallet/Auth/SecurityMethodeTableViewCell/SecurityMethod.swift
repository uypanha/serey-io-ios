//
//  SecurityMethod.swift
//  SereyIO
//
//  Created by Panha Uy on 6/15/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import LocalAuthentication

enum SecurityMethod {
    
    case fingerPrintID
    case faceID
    case googleOTP
    
    var iconImage: UIImage? {
        switch self {
        case .fingerPrintID:
            return R.image.fingerPrint()
        case .faceID:
            return R.image.faceID()
        case .googleOTP:
            return R.image.googleOTP()
        }
    }
    
    var title: String {
        switch self {
        case .fingerPrintID:
            return "FingerPrint ID"
        case .faceID:
            return "Face ID"
        case .googleOTP:
            return "Google Authentication App"
        }
    }
    
    var description: String {
        switch self {
        case .fingerPrintID:
            return "Set your finger to authorize your account"
        case .faceID:
            return "Set your face to authorize your account"
        case .googleOTP:
            return "Use google authentication app to generate verification"
        }
    }
    
    var isRecommended: Bool {
        return self == .fingerPrintID
    }
}

// MARK: - Extension Properties
extension SecurityMethod {
    
    static func supportedMethods() -> [SecurityMethod] {
        var methods: [SecurityMethod] = []
        let biometricType = LAContext().biometricType
        if biometricType != .none {
            methods.append(biometricType == .faceID ? .faceID : .fingerPrintID)
        }
        methods.append(.googleOTP)
        return methods
    }
}
