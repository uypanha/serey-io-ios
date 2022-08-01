//
//  PostDetailResponse.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/11/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

struct PostDetailResponse<T: Codable>: Codable {
    
    let content: T
    let replies: [PostModel]
    
    enum CodingKeys: String, CodingKey {
        case content
        case replies
    }
}
