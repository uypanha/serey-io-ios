//
//  PushApi.swift
//  SereyIO
//
//  Created by Panha Uy on 4/23/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import Moya

enum PushApi {
    
    case register(username: String, token: String)

    case remove(username: String)
}

extension PushApi: AuthorizedApiTargetType {
    
    var baseURL: URL {
        return Constants.kycURL
    }

    var parameters: [String : Any] {
        switch self {
        case .register(let data):
            return [
                "username"      : data.username,
                "token"         : data.token,
                "deviceType"    : "IOS"
            ]
        case .remove(let username):
            return [
                "username"      : username
            ]
        }
    }
    
    var path: String {
        switch self {
        case .register:
            return "/api/notification/user/register"
        case .remove:
            return "/api/notification/user/remove"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
