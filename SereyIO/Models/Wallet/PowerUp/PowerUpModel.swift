//
//  PowerUpModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/31/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

struct PowerUpModel: Codable {
    
    var message: String
    
    enum CodingKeys: String, CodingKey {
        case message
    }
}
