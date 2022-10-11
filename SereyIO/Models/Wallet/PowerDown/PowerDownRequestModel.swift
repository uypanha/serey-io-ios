//
//  PowerDownRequestModel.swift
//  SereyIO
//
//  Created by Panha Uy on 9/3/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

struct PowerDownRequestModel: Codable {
    
    var activeKey: String
    var amount: Double
    
    enum CodingKeys: String, CodingKey {
        case activeKey = "active_key"
        case amount
    }
}
