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
    
    case getPostDetail(permlink: String, authorName: String)
    
    case getCommentReply(username: String, type: GetCommentType)
    
    case submitPost(SubmitPostModel)
    
    case submitComment(SubmitCommentModel)
    
    case deletPost(username: String, permlink: String)
    
    case upVote(permlink: String, author: String, weight: Int)
    
    case flag(permlink: String, author: String, weight: Int)
    
    case downVote(permlink: String, author: String)
}

extension DiscussionApi: AuthorizedApiTargetType {
    
    var parameters: [String : Any] {
        switch self {
        case .getDiscussions(let data):
            return data.1.prepareParameters(data.0.authorParamName, authorName: data.0.authorName)
        case .getPostDetail(let data):
            return [
                "permlink"      : data.permlink,
                "authorName"    : data.authorName
            ]
        case .getCommentReply(let username, let type):
            return [
                "UserId"    : username,
                "typeId"    : type.typeId
            ]
        case .submitPost(let data):
            return data.parameters
        case .submitComment(let data):
            return data.parameters
        case .deletPost(let data):
            return [
                "username"  : data.username,
                "permlink"  : data.permlink
            ]
        case .upVote(let data):
            return [
                "author"    : data.author,
                "permlink"  : data.permlink,
                "weight"    : data.weight
            ]
        case .flag(let data):
            return [
                "author"    : data.author,
                "permlink"  : data.permlink,
                "weight"    : data.weight
            ]
        case .downVote(let data):
            return [
                "author"    : data.author,
                "permlink"  : data.permlink
            ]
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
        case .getPostDetail:
            return "/api/v1/sereyweb/findDetailBypermlink"
        case .getCommentReply:
            return "/api/v1/sereyweb/findRepliesOrCommentsByUserId"
        case .submitPost:
            return "/api/v1/sereyweb/submitPost"
        case .submitComment:
            return "/api/v1/sereyweb/submitReplies"
        case .deletPost:
            return "/api/v1/sereyweb/deletePost"
        case .upVote:
            return "/api/v1/vote/upvote"
        case .downVote:
            return "/api/v1/vote/downvote"
        case .flag:
            return "/api/v1/vote/flag"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .submitPost, .submitComment, .deletPost, .upVote, .downVote, .flag:
            return .post
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getDiscussions, .getPostDetail, .getCommentReply:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .submitPost, .submitComment, .deletPost, .upVote, .flag, .downVote:
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
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

enum GetCommentType {
    case comments
    case replies
    
    var typeId: String {
        switch self {
        case .comments:
            return "comments"
        case .replies:
            return "recent-replies"
        }
    }
}

// MARK: - QueryDiscussionsBy
extension QueryDiscussionsBy {
    
    func prepareParameters(_ authorFieldName: String = "authorName", authorName: String? = nil) -> [String: Any] {
        var parameters: [String: Any] = [:]
        if let permlink = start_permlink {
        parameters["permlink"] = permlink
        }
        if let authorName = authorName ?? start_author {
        parameters[authorFieldName] = authorName
        }
        if let categoryName = tag {
        parameters["categoryName"] = categoryName
        }
        parameters["limit"] = limit
        return parameters
    }
}
