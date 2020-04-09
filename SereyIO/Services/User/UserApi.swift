//
//  UserApi.swift
//  SereyIO
//
//  Created by Panha Uy on 3/18/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import Moya

enum UserApi {
    
    case profile(userName: String)
    
    case followAction(username: String, author: String)
}

extension UserApi: AuthorizedApiTargetType {
    
    var parameters: [String : Any] {
        switch self {
        case .followAction(let data):
            return [
                "username"      : data.username,
                "authorName"    : data.author
            ]
        default:
            return [:]
        }
    }
    
    var path: String {
        switch self {
        case .profile(let username):
            return "/api/v1/accounts/\(username)"
        case .followAction:
            return "/api/v1/follow/getFollowingbyUsername"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
