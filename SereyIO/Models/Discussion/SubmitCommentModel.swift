//
//  SubmitCommentModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/7/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

struct SubmitCommentModel {
    
    let parentAuthor: String
    let parentPermlink: String
    let title: String
    let body: String
    let mainCategory: String
    
    var parameters: [String: Any] {
        return [
            "title"             : self.title,
            "parent_author"     : self.parentAuthor,
            "parent_permlink"   : self.parentPermlink,
            "body"              : self.body,
            "maincategory"      : self.mainCategory
        ]
    }
}
