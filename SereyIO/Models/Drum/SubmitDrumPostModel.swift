//
//  SubmitDrumPostModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/8/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//
import Foundation

struct SubmitDrumPostModel {
    
    var permlink: String? = nil
    var title: String
    var body: String
    var shortDesc: String = ""
    var images: [String]
    
    var parameters: [String: Any] {
        var params: [String: Any] = [
            "title"             : self.title,
            "desc"              : self.shortDesc,
            "body"              : self.body,
            "images"            : self.images,
            "categories"        :"drum",
            "subcategories"     : [],
            "otherblockchain"   : true
        ]
        
        if let permlink = self.permlink {
            params["permlink"] = permlink
        }
        
        return params
    }
}
