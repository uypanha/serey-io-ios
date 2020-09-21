//
//  ClaimRewardModel.swift
//  SereyIO
//
//  Created by Panha Uy on 7/30/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

struct ClaimRewardModel: Codable {
    
    var message: String
    
    enum CodingKeys: String, CodingKey {
        case message = "Message"
    }
}
