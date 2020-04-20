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
    
    case getFollowAction(username: String, author: String)
    
    case getFollowerList(author: String)
    
    case followAction(author: String, actionType: FollowActionType)
}

extension UserApi: AuthorizedApiTargetType {
    
    var parameters: [String : Any] {
        switch self {
        case .getFollowAction(let data):
            return [
                "username"      : data.username,
                "authorName"    : data.author
            ]
        case .followAction(let data):
            return [
                "author"        : data.author,
                "actionType"    : data.actionType.typeText
            ]
        case .getFollowerList(let data):
            return [
                "username"  : data
            ]
        default:
            return [:]
        }
    }
    
    var path: String {
        switch self {
        case .profile(let username):
            return "/api/v1/accounts/\(username)"
        case .getFollowAction:
            return "/api/v1/follow/getFollowingbyUsername"
        case .followAction:
            return "/api/v1/follow/action"
        case .getFollowerList:
            return "/api/v1/follow/getFollowerList"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .followAction:
            return .post
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .followAction:
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        default:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}

// MARK: - Follow Action Type
enum FollowActionType {
    case follow
    case unfollow
    
    var typeText: String {
        switch self {
        case .follow:
            return "follow"
        case .unfollow:
            return "unfollow"
        }
    }
}
