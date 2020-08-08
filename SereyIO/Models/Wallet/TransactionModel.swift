//
//  TransactionModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

struct TransactionModel: Codable {
    
    var trxId: String
    var block: Int
    var trxInBlock: Int
    var opInTrx: Int
    var virtualOp: Int
    var timestamp: String
    
    var createDateString: String? {
        get {
            guard let date = Date.date(from: self.timestamp, format: "yyyy-MM-dd'T'HH:mm:ss") else { return nil }
            
            return date.format("HH:mm, yyy.MM.dd")
        }
    }
    
    var typeImage: UIImage? {
        get {
            return R.image.transactionReceive()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case trxId = "trx_id"
        case block
        case trxInBlock = "trx_in_block"
        case opInTrx = "op_in_trx"
        case virtualOp = "virtual_op"
        case timestamp
    }
    
}

struct OpModel: Codable {
    
}

//{
//  "trx_id": "da9f5851aa523b21533ed4140e1929619df24243",
//  "block": 2245788,
//  "trx_in_block": 0,
//  "op_in_trx": 1,
//  "virtual_op": 0,
//  "timestamp": "2020-04-02T02:02:18",
//  "op": [
//    "transfer_to_vesting",
//    {
//      "from": "serey",
//      "to": "panhauy",
//      "amount": "20.000 SEREY"
//    }
//  ]
//}
