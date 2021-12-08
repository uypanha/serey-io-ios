//
//  UserProfileModel.swift
//  SereyIO
//
//  Created by Mäd on 08/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class UserProfileModel: Object, Codable {
    
    @objc dynamic var id: String = ""
    @objc dynamic var username: String = ""
    @objc dynamic var imageUrl: String = ""
    @objc dynamic var active: Bool = false
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case imageUrl = "image_url"
        case active
    }
}
