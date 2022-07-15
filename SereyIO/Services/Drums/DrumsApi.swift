//
//  DrumsApi.swift
//  SereyIO
//
//  Created by Panha Uy on 30/6/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import Moya

enum DrumsApi {
    
    case allDrums(String?, PaginationRequestModel)
}

extension DrumsApi: AuthorizedApiTargetType {
    
    var parameters: [String : Any] {
        switch self {
        case .allDrums(let author, let pagination):
            var parameters = pagination.parameters
            if let author = author {
                parameters["author"] = author
            }
            return parameters
        }
    }
    
    var path: String {
        switch self {
        case .allDrums(let author, _):
            if author != nil {
                return "/api/v1/sereyweb/get_all_drum_posts_by_author"
            }
            return "/api/v1/sereyweb/get_all_drum_posts"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .allDrums:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
