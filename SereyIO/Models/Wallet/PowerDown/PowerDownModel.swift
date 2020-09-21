//
//  PowerDownModel.swift
//  SereyIO
//
//  Created by Panha Uy on 9/3/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

struct PowerDownModel: Codable {
    
    var message: String
    
    enum CodingKeys: String, CodingKey {
        case message
    }
}
