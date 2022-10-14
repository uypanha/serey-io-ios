//
//  TransferCoinRequestModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/4/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

struct TransferCoinRequestModel: Codable {
    
    var activeKey: String
    var account: String
    var amount: Double
    var memo: String
    
    enum CodingKeys: String, CodingKey {
        case activeKey = "active_key"
        case account
        case amount
        case memo
    }
}
