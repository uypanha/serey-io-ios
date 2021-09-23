//
//  PaginationRequestModel.swift
//  SereyIO
//
//  Created by Panha Uy on 6/28/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation

public struct PaginationRequestModel: PaginationRequestProtocol {
    
    var query: String? = nil
    var tag: String? = nil
    var offset: Int = 0
    var limit: Int = Constants.limitPerPage
    
    mutating func reset() {
        self.query = nil
        self.offset = 0
    }
    
    var parameters: [String: Any] {
        get {
            var parameters: [String: Any] = [
                "offset"        : "\(offset)",
                "limit"         : "\(limit)"
            ]
            if let textQuery = query {
                parameters["text_query"] = textQuery
            }
            if let tag = self.tag {
                parameters["tag"] = tag
            }
            return parameters
        }
    }
}
