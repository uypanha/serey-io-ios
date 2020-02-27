//
//  DiscussionCategoryModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/26/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

class DiscussionCategoryModel: Codable {
    
    var name: String
    var sub: [DiscussionCategoryModel]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case sub
    }
}
