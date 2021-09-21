//
//  UserModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/18/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

@objcMembers class UserModel: Object, Codable {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var reputation: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var postCount: Int = 0
    @objc dynamic var commentCount: Int = 0
    @objc dynamic var joinDate: String = ""
    @objc dynamic var balance: String = ""
    @objc dynamic var sereypower: String = ""
    @objc dynamic var followingCount: Int = 0
    @objc dynamic var followersCount: Int = 0
    @objc dynamic var profilePicture: String? = nil
    @objc dynamic var recoveryAccount: String? = nil
    @objc dynamic var isClaimReward: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case reputation
        case name
        case postCount
        case commentCount
        case joinDate
        case balance
        case sereypower
        case followingCount
        case followersCount
        case profilePicture
        case recoveryAccount = "recovery_account"
        case isClaimReward
    }
}

// MARK: - Extensions
extension UserModel {
    
    var profileModel: ProfileViewModel {
        let firstLetter = name.first == nil ? "" : "\(name.first!)"
        let uniqueColor = UIColor(hexString: PFColorHash().hex("\(name)"))
        return ProfileViewModel(shortcut: firstLetter, imageUrl: nil, uniqueColor: uniqueColor)
    }
}
