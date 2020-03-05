//
//  ListDataResponseModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/4/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

struct ListDataResponseModel<T: Codable>: Codable {
    
    let message: String
    let data: [T]
    
    enum CodingKeys: String, CodingKey {
        case message
        case data
    }
}
