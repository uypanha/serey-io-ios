//
//  DiscussionCategoryModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/26/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

struct DiscussionCategoryModel: Codable {
    
    var parent: String? = nil
    var name: String
    var sub: [DiscussionCategoryModel]?
    
    var subCategories: [DiscussionCategoryModel]? {
        return self.sub?.map { DiscussionCategoryModel(parent: name, name: $0.name, sub: $0.sub) }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case sub
    }
}
