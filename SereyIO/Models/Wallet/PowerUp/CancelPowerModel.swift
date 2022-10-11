//
//  CancelPowerModel.swift
//  SereyIO
//
//  Created by Panha Uy on 9/4/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

struct CancelPowerModel: Codable {
    
    var message: String
    
    enum CodingKeys: String, CodingKey {
        case message
    }
}
