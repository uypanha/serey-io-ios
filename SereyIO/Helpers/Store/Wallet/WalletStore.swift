//
//  WalletStore.swift
//  SereyIO
//
//  Created by Panha Uy on 7/25/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import Steem

class WalletStore {
    
    static let shared = WalletStore()
    
    func savePassword(username: String, password: String) {
        do {
            // This is a new account, create a new keychain item with the account name.
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.touchMeInServiceName, account: username, accessGroup: KeychainConfiguration.accessGroup)
            
            // Save the password for the new item.
            try passwordItem.savePassword(password)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
    }
    
    func password(from username: String) -> String? {
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.touchMeInServiceName,
                                                account: username,
                                                accessGroup: KeychainConfiguration.accessGroup)
        let keychainPassword = try? passwordItem.readPassword()
        return keychainPassword
    }
    
    func hasPassword(for username: String) -> Bool {
        return password(from: username) != nil
    }
    
    func removeAllPassword() {
        if let keyItems = try? KeychainPasswordItem.passwordItems(forService: KeychainConfiguration.touchMeInServiceName, accessGroup: KeychainConfiguration.accessGroup) {
            keyItems.forEach { passwordItem in
                try? passwordItem.deleteItem()
            }
        }
    }
}
