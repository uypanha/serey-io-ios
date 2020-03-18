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
}

extension AuthApi: AuthorizedApiTargetType {
    
    var parameters: [String : Any] {
        switch self {
        case .login(let data):
            return [
                "username"  : data.userName,
                "password"  : data.password
            ]
        }
    }
    
    var path: String {
        switch self {
        case .login:
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
