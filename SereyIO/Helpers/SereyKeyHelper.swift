//
//  SereyKeyHelper.swift
//  SereyIO
//
//  Created by Panha Uy on 7/25/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import Steem

class SereyKeyHelper {
    
    enum RoleType: String {
        case owner = "owner"
        case active = "active"
        case posting = "posting"
        case memo = "memo"
    }
    
    static func generateKeys(_ username: String, key: String) -> [String] {
        return [RoleType.owner, .active, .posting, .memo].map { role in
            return generateKey(from: username, ownerKey: key, type: role)?.wif ?? ""
        }
    }
    
    static func generateKey(from username: String, ownerKey: String, type: RoleType) -> PrivateKey? {
        return PrivateKey(seed: "\(username)\(type.rawValue)\(ownerKey)")
    }
}
