//
//  AuthApi.swift
//  SereyIO
//
//  Created by Panha Uy on 3/15/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import Moya

enum AuthApi {
    
    case login(userName: String, password: String)
    
    case loginOwner(username: String, ownerKey: String)
}

extension AuthApi: AuthorizedApiTargetType {
    
    var parameters: [String : Any] {
        switch self {
        case .login(let userName, let password):
            return [
                "username"  : userName,
                "password"  : password,
                "rememberMe": true
            ]
        case .loginOwner(let userName, let password):
            return [
                "username"  : userName,
                "password"  : password
            ]
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "/api/v1/authentications/loginKyc"
        case .loginOwner:
            return "/api/v1/authentications/login"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
