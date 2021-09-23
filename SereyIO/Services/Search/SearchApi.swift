//
//  SearchApi.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/4/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import Moya

enum SearchApi {
    
    case search(PaginationRequestModel)
}

extension SearchApi: AuthorizedApiTargetType {

    var parameters: [String : Any] {
        switch self {
        case .search(let pageModel):
            return pageModel.parameters
        }
    }
    
    var path: String {
        switch self {
        case .search:
            return "/api/v1/sereyweb/getAllPostsByNew"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .search:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
