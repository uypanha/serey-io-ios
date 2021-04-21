//
//  PushApi.swift
//  SereyIO
//
//  Created by Panha Uy on 4/23/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import Moya

enum PushApi {
    
    case register(username: String, token: String)

    case remove(username: String)
    
    case updateToken(username: String, token: String)
    
    case login
}

extension PushApi: AuthorizedApiTargetType {
    
    var baseURL: URL {
        return Constants.notificationCenterUrl
    }

    var parameters: [String : Any] {
        switch self {
        case .register(let username, let token):
            return [
                "username"      : username,
                "token"         : token,
                "deviceType"    : "IOS"
            ]
        case .remove(let username):
            return [
                "username"      : username
            ]
        case .updateToken(let username, let token):
            return [
                "username"      : username,
                "newToken"      : token
            ]
        case .login:
            return [
                "username"      : "mobile",
                "password"      : "kgx?tMjn@RhBqQ4<",
                "rememberMe"    : true
            ]
        }
    }
    
    var path: String {
        switch self {
        case .register:
            return "/api/notification/user/register"
        case .remove:
            return "/api/notification/user/remove"
        case .login:
            return "/api/notification/user/login"
        case .updateToken:
            return "/api/notification/user/update"
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
