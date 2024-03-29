//
//  PowerUpRequestModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/30/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

struct PowerUpRequestModel: Codable {
    
    var activeKey: String
    var account: String
    var amount: Double
    
    enum CodingKeys: String, CodingKey {
        case activeKey = "active_key"
        case account
        case amount
    }
}
