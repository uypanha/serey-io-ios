//
//  UserProfileApi.swift
//  SereyIO
//
//  Created by Mäd on 07/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation
import Moya

enum UserProfileApi {
    case getAllUserProfilePicture(String)
    
    case addUserProfile(String)
    
    case changeProfile(String)
}

extension UserProfileApi: AuthorizedApiTargetType {
    
    var parameters: [String : Any] {
        switch self {
        case .getAllUserProfilePicture(let username):
            return [
                "username"  : username
            ]
        case .addUserProfile(let url):
            return [
                "image_url"      : url
            ]
        case .changeProfile(let id):
            return [
                "id"    : id
            ]
        }
    }
    
    var path: String {
        switch self {
        case .getAllUserProfilePicture:
            return "/api/v1/user_profile_picture/get_all_user_profile_picture_by_username"
        case .addUserProfile:
            return "/api/v1/user_profile_picture/add_user_profile_picture"
        case .changeProfile:
            return "api/v1/user_profile_picture/change_user_profile_picture"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAllUserProfilePicture:
            return .get
        case .addUserProfile:
            return .post
        case .changeProfile:
            return .put
        }
    }
    
    var task: Task {
        switch self {
        case .getAllUserProfilePicture:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .addUserProfile, .changeProfile:
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
