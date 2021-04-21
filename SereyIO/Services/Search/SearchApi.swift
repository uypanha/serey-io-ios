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
    
    case searchAuthor(query: String)
}

extension SearchApi: AuthorizedApiTargetType {

    var parameters: [String : Any] {
        switch self {
        case .searchAuthor(let query):
            return [
                "name" : query
            ]
        }
    }
    
    var path: String {
        switch self {
        case .searchAuthor:
            return "/api/v1/accounts/findUser"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .searchAuthor:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
