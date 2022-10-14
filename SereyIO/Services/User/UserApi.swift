//
//  UserApi.swift
//  SereyIO
//
//  Created by Panha Uy on 3/18/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import Moya

enum UserApi {
    
    case iPTrace
    
    case profile(userName: String)
    
    case getFollowAction(username: String, author: String)
    
    case getFollowerList(author: String)
    
    case followAction(author: String, actionType: FollowActionType)
    
    case changePassword(current: String, new: String)
    
    case getReferralCode(String)
    
    case addReferralId(String)
}

extension UserApi: AuthorizedApiTargetType {
    
    public var baseURL: URL {
        switch self {
        case .iPTrace:
            return URL(string: "https://www.cloudflare.com")!
        default:
            return Constants.apiEndPoint
        }
    }
    
    var parameters: [String : Any] {
        switch self {
        case .getFollowAction(let username, let author):
            return [
                "username"      : username,
                "authorName"    : author
            ]
        case .followAction(let author, let actionType):
            return [
                "author"        : author,
                "actionType"    : actionType.typeText
            ]
        case .getFollowerList(let data):
            return [
                "username"  : data
            ]
        case .changePassword(let current, let new):
            return [
               "currentPassword"    : current,
               "newPassword"        : new
            ]
        default:
            return [:]
        }
    }
    
    var path: String {
        switch self {
        case .iPTrace:
            return "/cdn-cgi/trace"
        case .profile(let username):
            return "/api/v1/accounts/\(username)"
        case .getFollowAction:
            return "/api/v1/follow/getFollowingbyUsername"
        case .followAction:
            return "/api/v1/follow/action"
        case .getFollowerList:
            return "/api/v1/follow/getFollowerList"
        case .changePassword:
            return "/api/v1/accounts/changePassword"
        case .getReferralCode(let username):
            return "/api/v1/general/get_referal_id/\(username)"
        case .addReferralId(let username):
            return "/api/v1/general/add_referal_id/\(username)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .followAction, .changePassword, .addReferralId:
            return .post
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .followAction, .changePassword, .addReferralId:
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        default:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getReferralCode, .addReferralId:
            return [
                "token" : AuthData.shared.userToken ?? ""
            ]
        default:
            return [:]
        }
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
