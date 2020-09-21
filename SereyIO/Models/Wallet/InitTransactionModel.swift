//
//  InitTransactionModel.swift
//  SereyIO
//
//  Created by Panha Uy on 7/28/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

class InitTransactionModel: Codable {
    
    var trxId: Int
    var publicKey: String
    
    enum CodingKeys: String, CodingKey {
        case trxId
        case publicKey
    }
}
