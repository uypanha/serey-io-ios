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
            return Store.standard.value(forKey: Constants.UserDefaultsKeys.userDisabledNotifs.rawValue) as? Bool ?? false
        }
        set {
            Store.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.userDisabledNotifs.rawValue)
        }
    }
    
    var currentUserCountry: String? {
        get {
            return Store.standard.value(forKey: "currentUserCountry") as? String
        }
        set {
            Store.standard.setValue(newValue, forKey: "currentUserCountry")
        }
    }
    
    var currentUserCountryIconUrl: String? {
        get {
            return Store.standard.value(forKey: "currentUserCountryIconUrl") as? String
        } set {
            Store.standard.setValue(newValue, forKey: "currentUserCountryIconUrl")
        }
    }
    
    var currentCountry: CountryModel? {
        guard let countryName = self.currentUserCountry else { return nil }
        return CountryModel(countryName: countryName, iconUrl: self.currentUserCountryIconUrl)
    }
    
    func setNotification(_ enabled: Bool) {
        self.userDisabledNotifs = !enabled
        if enabled {
            AppDelegate.shared?.turnOnPushNotification()
        } else {
            AppDelegate.shared?.turnOffPushNotification()
        }
    }
    
    func setFeautureSeen(of feature: FeatureBoarding, seen: Bool) {
        Store.standard.setValue(seen, forKey: feature.preferenceKey)
    }
}
