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
}

extension UserApi: AuthorizedApiTargetType {
    
    var parameters: [String : Any] {
        switch self {
        case .profile(let data):
            return [
                "username"  : data
            ]
        }
    }
    
    var path: String {
        switch self {
        case .profile:
            return "/api/v1/accounts/getUserProfile"
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