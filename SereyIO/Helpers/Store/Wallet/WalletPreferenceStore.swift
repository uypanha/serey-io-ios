//
//  WalletPreferenceStore.swift
//  SereyIO
//
//  Created by Panha Uy on 10/15/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

class WalletPreferenceStore {
    
    static let shared = WalletPreferenceStore()
    private var username: String {
        get {
            return AuthData.shared.username ?? ""
        }
    }
    
    var googleOTPEnabled: Bool {
        get {
            return self.googleOTPSecret != nil
        }
    }
    
    private(set) var biometryEnabled: Bool {
        get {
            return Store.secure.value(forKey: "\(username).biometryEnabled") as? Bool ?? false
        }
        set {
            Store.secure.setValue(newValue, forKey: "\(username).biometryEnabled")
        }
    }
    
    private(set) var googleOTPSecret: String? {
        get {
            return Store.secure.value(forKey: "\(username).googleOTPSecret") as? String
        }
        set {
            Store.secure.setValue(newValue, forKey: "\(username).googleOTPSecret")
        }
    }
    
    func enableGoogleOTP(_ secret: String) {
        self.disableBiometry()
        self.googleOTPSecret = secret
    }
    
    func enableBiometry() {
        self.disableGoogleOTP()
        self.biometryEnabled = true
    }
    
    func disableGoogleOTP() {
        self.googleOTPSecret = nil
    }
    
    func disableBiometry() {
        self.biometryEnabled = false
    }
    
    func disableAllSecurity() {
        self.disableBiometry()
        self.disableGoogleOTP()
    }
}
