//
//  UserModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/18/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

@objcMembers class UserModel: Object, Codable {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var postCount: Int = 0
    @objc dynamic var commentCount: Int = 0
    @objc dynamic var joinDate: String = ""
    @objc dynamic var balance: Double = 0
    @objc dynamic var recoveryAccount: String? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case postCount
        case commentCount
        case joinDate
        case balance
        case recoveryAccount = "recovery_account"
    }
}
