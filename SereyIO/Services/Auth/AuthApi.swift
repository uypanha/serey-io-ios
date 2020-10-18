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
    
    case checkUsername(username: String, publicKey: String)
    
    case signUpWallet(username: String, postingPriKey: String, password: String, requestToken: String)
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
        case .checkUsername(let username, let publicKey):
            return [
                "username"      : username,
                "postingPubkey" : publicKey
            ]
        case .signUpWallet(let username, let postingPriKey, let password, let requestToken):
            return [
                "postingkey"    : postingPriKey,
                "username"      : username,
                "password"      : password,
                "avatar"        : "user",
                "profileUrl"    : "",
                "requestToken"  : requestToken
            ]
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "/api/v1/authentications/loginKyc"
        case .loginOwner:
            return "/api/v1/authentications/login"
        case .checkUsername:
            return "/api/v1/accounts/checkUsername"
        case .signUpWallet:
            return "/api/v1/accounts/signUp"
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
