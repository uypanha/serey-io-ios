//
//  TickerModel.swift
//  SereyIO
//
//  Created by Mäd on 20/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

@objcMembers class TickerModel: Object, Codable {
    
    @objc dynamic var id = 0
    @objc dynamic var price: String = ""
    
    var sereyPrice: Double {
        return Double(price) ?? 0
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    enum CodingKeys: String, CodingKey {
        case price
    }
}
