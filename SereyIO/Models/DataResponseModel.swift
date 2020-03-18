//
//  DataResponseModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/18/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

class DataResponseModel<T: Codable>: Codable {
    
    let message: String
    let data: T
    
    enum CodingKeys: String, CodingKey {
        case message
        case data
    }
}
