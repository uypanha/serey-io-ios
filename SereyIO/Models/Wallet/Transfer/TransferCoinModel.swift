//
//  TransferCoinModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/4/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

struct TransferCoinModel: Codable {
    
    var message: String
    
    enum CodingKeys: String, CodingKey {
        case message
    }
}
