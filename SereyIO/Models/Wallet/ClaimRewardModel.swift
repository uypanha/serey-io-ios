//
//  ClaimRewardModel.swift
//  SereyIO
//
//  Created by Panha Uy on 7/30/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

struct ClaimRewardModel: Codable {
    
    var message: String?
    var Message: String?
    
    enum CodingKeys: String, CodingKey {
        case message = "message"
        case Message = "Message"
    }
}
