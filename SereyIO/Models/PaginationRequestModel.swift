//
//  PaginationRequestModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 1/11/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

import Foundation

public struct PaginationRequestModel {
    
    var query: String?
    var page: Int
    var limit: Int
    
    init(_ page: Int, _ limit: Int = Constants.limitPerPage, query: String? = nil) {
        self.query = query
        self.page = page
        self.limit = limit
    }
    
    var parameters: [String: Any] {
        get {
            return [
                "query" : query ?? "",
                "page"  : "\(page)",
                "pageSize" : "\(limit)"
            ]
        }
    }
}
