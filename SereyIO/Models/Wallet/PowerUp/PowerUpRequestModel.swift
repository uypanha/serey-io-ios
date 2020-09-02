//
//  PowerUpRequestModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/30/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

struct PowerUpRequestModel: Codable {
    
    var activeKey: String
    var account: String
    var amount: String
    
    enum CodingKeys: String, CodingKey {
        case activeKey = "active_key"
        case account
        case amount
    }
}
