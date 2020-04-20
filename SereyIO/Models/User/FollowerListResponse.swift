//
//  FollowerListResponse.swift
//  SereyIO
//
//  Created by Panha Uy on 4/20/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

struct FollowerListResponse: Codable {
    
    let statusCode: Int
    let followerList: [String]
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case followerList
    }
}
