//
//  DefaultsStore.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import Foundation

class DefaultsStore: SimpleStore {
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    func setValue(_ value: Any?, forKey key: String) {
        if let value = value {
            defaults.set(value, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()
    }
    
    func value(forKey key: String) -> Any? {
        if let val = defaults.value(forKey: key) {
            return val
        }
        return nil
    }
}

