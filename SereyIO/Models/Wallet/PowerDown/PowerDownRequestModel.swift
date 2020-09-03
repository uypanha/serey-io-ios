//
//  PowerDownRequestModel.swift
//  SereyIO
//
//  Created by Panha Uy on 9/3/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

struct PowerDownRequestModel: Codable {
    
    var activeKey: String
    var amount: String
    
    enum CodingKeys: String, CodingKey {
        case activeKey = "active_key"
        case amount
    }
}
