//
//  DiscussionApi.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/26/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import Moya

enum DiscussionApi {
    
    case getCategories
    
    case getDiscussions(DiscussionType, QueryDiscussionsBy)
}

extension DiscussionApi: AuthorizedApiTargetType {
    
    var parameters: [String : Any] {
        switch self {
        case .getDiscussions(let data):
            return data.1.prepareParameters(data.0 == .byUser ? "userId" : "authorName")
        default:
            return [:]
        }
    }
    
    var path: String {
        switch self {
        case .getCategories:
            return "/api/v1/sereyweb/getAllWebCategories"
        case .getDiscussions(let data):
            return "/api/v1/sereyweb/\(data.0.path)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .getDiscussions:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}

// MARK: - Discussion Type
fileprivate extension DiscussionType {
    
    var path: String {
        switch self {
        case .trending:
            return "getPostsByTrending"
        case .hot:
            return "getPostsByHot"
        case .new:
            return "findByNew"
        case .byUser:
            return "findByUserId"
        }
    }
}

// MARK: - QueryDiscussionsBy
extension QueryDiscussionsBy {
    
    func prepareParameters(_ authorFieldName: String = "authorName") -> [String: Any] {
        var parameters: [String: Any] = [:]
        if let permlink = start_permlink {
        parameters["permlink"] = permlink
        }
        if let authorName = start_author {
        parameters[authorFieldName] = authorName
        }
        if let categoryName = tag {
        parameters["categoryName"] = categoryName
        }
        parameters["limit"] = limit
        return parameters
    }
}
