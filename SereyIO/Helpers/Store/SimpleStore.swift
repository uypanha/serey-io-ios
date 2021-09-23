//
//  SimpleStore.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

/// Represents simple store allowing to save, read and delete values for keys.
protocol SimpleStore {
    
    /// Sets value for given key in this store. If value is nil then value is removed.
    ///
    /// - Parameters:
    ///   - value: Value to be saved
    ///   - key: Key
    func setValue(_ value: Any?, forKey key: String)
    
    /// Reads value for given key from this store.
    ///
    /// - Parameter key: Key
    /// - Returns: Value for given key. If no value for key is found nil is returned.
    func value(forKey key: String) -> Any?
    
}
