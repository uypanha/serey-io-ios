//
//  WalletPreferenceStore.swift
//  SereyIO
//
//  Created by Panha Uy on 10/15/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

class WalletPreferenceStore {
    
    static let shared = WalletPreferenceStore()
    
    var googleOTPEnabled: Bool {
        get {
            return self.googleOTPSecret != nil
        }
    }
    
    private(set) var googleOTPSecret: String? {
        get {
            return Store.secure.value(forKey: "googleOTPSecret") as? String
        }
        set {
            Store.secure.setValue(newValue, forKey: "googleOTPSecret")
        }
    }
    
    func enableGoogleOTP(_ secret: String) {
        self.googleOTPSecret = secret
    }
    
    func disableGoogleOTP() {
        self.googleOTPSecret = nil
    }
}
