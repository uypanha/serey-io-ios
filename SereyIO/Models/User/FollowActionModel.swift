//
//  FollowActionModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/20/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

struct FollowActionModel: Codable {
    
    let statusCode: Int
    let action: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case action
        case message
    }
}
