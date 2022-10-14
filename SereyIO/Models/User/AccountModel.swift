//
//  AccountModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/18/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

class AccountModel: Codable {
    
    var result: UserModel
    
    enum CodingKeys: String, CodingKey {
        case result
    }
}
