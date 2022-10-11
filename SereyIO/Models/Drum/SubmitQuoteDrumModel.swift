//
//  SubmitQuoteDrumModel.swift
//  SereyIO
//
//  Created by Panha Uy on 19/8/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation

struct SubmitQuoteDrumModel {
    
    var postAuthor: String
    var postPermlink: String
    var title: String
    var permlink: String?
    var desc: String
    var body: String
    var images: [String]
    
    var parameters: [String: Any] {
        var params: [String: Any] = [
            "post_author"       : self.postAuthor,
            "post_permlink"     : self.postPermlink,
            "title"             : self.title,
            "desc"              : self.desc,
            "body"              : self.body,
            "images"            : self.images,
        ]
        
        if let permlink = self.permlink {
            params["permlink"] = permlink
        }
        
        return params
    }
}
