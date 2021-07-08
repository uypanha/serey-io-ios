//
//  PreferenceStore.swift
//  SereyIO
//
//  Created by Panha Uy on 4/28/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import CountryPicker

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
    
    var currentUserCountryCode: String? {
        get {
            return Store.standard.value(forKey: "currentUserCountryCode") as? String
        }
        set {
            Store.standard.setValue(newValue, forKey: "currentUserCountryCode")
        }
    }
    
    var currentCountry: Country? {
        guard let countryCode = self.currentUserCountryCode else { return nil }
        return CountryManager.shared.country(withCode: countryCode)
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
