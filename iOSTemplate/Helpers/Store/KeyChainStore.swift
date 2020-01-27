//
//  KeyChainStore.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import Foundation
import Locksmith

class KeychainStore: SimpleStore {
    
    private let rootDataKey = "data"
    
    func setValue(_ value: Any?, forKey key: String) {
        if let value = value {
            do {
                try Locksmith.saveOrUpdateData(data: [rootDataKey: value], forUserAccount: key)
            } catch {
                log.error("Could not save or update data to keychain for key: \(key)")
                if let error = error as? LocksmithError {
                    log.error(error.log())
                }
            }
        } else {
            do {
                try Locksmith.safelyDeleteDataForUserAccount(userAccount: key)
            } catch {
                log.error("Could not delete data from keychain for key: \(key)]")
                if let error = error as? LocksmithError {
                    log.error(error.log())
                }
            }
        }
    }
    
    func value(forKey key: String) -> Any? {
        if let data = Locksmith.loadDataForUserAccount(userAccount: key), let value = data[rootDataKey] {
            return value
        }
        return nil
    }
}

fileprivate extension Locksmith {
    static func saveOrUpdateData(data: [String: Any], forUserAccount userAccount: String, inService service: String = LocksmithDefaultService) throws {
        if Locksmith.loadDataForUserAccount(userAccount: userAccount) != nil {
            try Locksmith.updateData(data: data, forUserAccount: userAccount)
        } else {
            try Locksmith.saveData(data: data, forUserAccount: userAccount)
        }
    }
    
    static func safelyDeleteDataForUserAccount(userAccount: String, inService service: String = LocksmithDefaultService) throws {
        if Locksmith.loadDataForUserAccount(userAccount: userAccount) != nil {
            try Locksmith.deleteDataForUserAccount(userAccount: userAccount)
        }
    }
}

fileprivate extension LocksmithError {
    func log() -> String {
        return "LockSmithError [\(self)]: \(self.rawValue)"
    }
}
