//
//  PreferenceStore.swift
//  SereyIO
//
//  Created by Panha Uy on 4/28/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

class PreferenceStore {
    
    static let shared = PreferenceStore()
    
    var isAppRunBefore: Bool {
        get {
            return Store.standard.value(forKey: Constants.UserDefaultsKeys.appHasRunBefore.rawValue) as? Bool ?? false
        }
        set {
            Store.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.appHasRunBefore.rawValue)
        }
    }
    
    private(set) var userDisabledNotifs: Bool {
        get {
            return Store.standard.value(forKey: Constants.UserDefaultsKeys.userDisabledNotifs.rawValue) as? Bool ?? true
        }
        set {
            Store.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.userDisabledNotifs.rawValue)
        }
    }
    
    func setNotification(_ enabled: Bool) {
        self.userDisabledNotifs = !enabled
        if enabled {
            AppDelegate.shared?.turnOnPushNotification()
        } else {
            AppDelegate.shared?.turnOffPushNotification()
        }
    }
}
