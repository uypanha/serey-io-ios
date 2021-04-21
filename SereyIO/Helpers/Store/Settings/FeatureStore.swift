//
//  FeatureStore.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/3/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

class FeatureStore {
    
    private static let areFeaturesIntroducedKey = "features.areFeaturesIntroduced"
    
    static let shared = FeatureStore()
    
    var areFeaturesIntroduced: Bool {
        get {
            return (Store.standard.value(forKey: FeatureStore.areFeaturesIntroducedKey) as? Bool) ?? false
        }
        set {
            Store.standard.setValue(newValue, forKey: FeatureStore.areFeaturesIntroducedKey)
        }
    }
}
