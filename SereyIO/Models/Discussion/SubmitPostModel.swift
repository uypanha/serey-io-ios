//
//  SubmitPostModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

struct SubmitPostModel {
    
    let permlink: String?
    let title: String
    let shortDesc: String
    let body: String
    let categories: String
    let subcategories: [String]
    let images: [String]
    
    var parameters: [String: Any] {
        var params: [String: Any] = [
            "title"         : self.title,
            "desc"          : self.shortDesc,
            "body"          : self.body,
            "categories"    : self.categories,
            "subcategories" : self.subcategories,
            "images"        : self.images
        ]
        
        if let permlink = self.permlink {
            params["permlink"] = permlink
        }
        
        return params
    }
}

