//
//  SignUpWalletModel.swift
//  SereyIO
//
//  Created by Panha Uy on 9/26/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

struct SignUpWalletModel: Codable {
    
    var statusCode: Int
    var message: String
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case message
    }
}
