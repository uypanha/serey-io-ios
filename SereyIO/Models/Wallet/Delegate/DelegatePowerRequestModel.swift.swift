//
//  DelegatePowerRequestModel.swift.swift
//  SereyIO
//
//  Created by Panha Uy on 11/8/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation

struct DelegatePowerRequestModel: Codable {
    
    var activeKey: String
    var account: String
    var amount: Double
    
    enum CodingKeys: String, CodingKey {
        case activeKey = "active_key"
        case account
        case amount
    }
}
