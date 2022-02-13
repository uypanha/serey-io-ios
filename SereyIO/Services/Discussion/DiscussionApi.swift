//
//  DiscussionApi.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/26/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import Moya
import CountryPicker

enum DiscussionApi {
    
    case getCategories
    
    case getDiscussions(DiscussionType, PaginationRequestModel)
    
    case getPostDetail(permlink: String, authorName: String)
    
    case getCommentReply(username: String, type: GetCommentType)
    
    case submitPost(SubmitPostModel)
    
    case submitComment(SubmitCommentModel)
    
    case deletPost(username: String, permlink: String)
    
    case upVote(permlink: String, author: String, weight: Int)
    
    case flag(permlink: String, author: String, weight: Int)
    
    case downVote(permlink: String, author: String)
    
    case getSereyCountries
    
    case getReportTypes
    
    case reportPost(postId: String, typeId: String, description: String)
    
    case hidePost(String)
    
    case unhidePost(String)
}

extension DiscussionApi: AuthorizedApiTargetType {
    
    var parameters: [String : Any] {
        switch self {
        case .getCategories:
            if let country = PreferenceStore.shared.currentCountry {
                return [ "type" : country.countryName.lowercased() ]
            }
            return [:]
        case .getDiscussions(let type, let pageModel):
            var parameters: [String: Any] = pageModel.parameters
            type.params.forEach { param in
                parameters[param.key] = param.value
            }
            if let country = PreferenceStore.shared.currentCountry {
                parameters["country_name"] = country.countryName
            }
            return parameters
        case .getPostDetail(let permlink, let authorName):
            return [
                "permlink"      : permlink,
                "authorName"    : authorName
            ]
        case .getCommentReply(let username, let type):
            return [
                "UserId"    : username,
                "typeId"    : type.typeId
            ]
        case .submitPost(let data):
            var parameters = data.parameters
            if let country = PreferenceStore.shared.currentCountry {
                parameters["country_name"] = country.countryName
            }
            return parameters
        case .submitComment(let data):
            return data.parameters
        case .deletPost(let username, let permlink):
            return [
                "username"  : username,
                "permlink"  : permlink
            ]
        case .upVote(let permlink, let author, let weight):
            return [
                "author"    : author,
                "permlink"  : permlink,
                "weight"    : weight
            ]
        case .flag(let permlink, let author, let weight):
            return [
                "author"    : author,
                "permlink"  : permlink,
                "weight"    : weight
            ]
        case .downVote(let permlink, let author):
            return [
                "author"    : author,
                "permlink"  : permlink
            ]
        case .reportPost(let postId, let typeId, let description):
            return [
                "post_id" : postId,
                "report_type_id" : typeId,
                "description" : description
            ]
        case .hidePost(let id):
            return [
                "post_id"   : id
            ]
        case .unhidePost(let id):
            return [
                "post_id"   : id
            ]
        default:
            return [:]
        }
    }
    
    var path: String {
        switch self {
        case .getCategories:
            return "/api/v1/sereyweb/getAllWebCategories"
        case .getDiscussions(let type, _):
            return "/api/v1/sereyweb/\(type.path)"
        case .getPostDetail:
            return "/api/v1/sereyweb/getDetailByPermlink"
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
        case .getSereyCountries:
            return "/api/v1/general/get_serey_countries"
        case .getReportTypes:
            return "/api/v1/general/get_report_types"
        case .reportPost:
            return "/api/v1/general/report_posts"
        case .hidePost:
            return "/api/v1/general/hide_posts"
        case .unhidePost:
            return "/api/v1/general/unhide_posts"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .submitPost, .submitComment, .deletPost, .upVote, .downVote, .flag, .reportPost, .hidePost, .unhidePost:
            return .post
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getDiscussions, .getPostDetail, .getCommentReply, .getCategories, .getSereyCountries, .getReportTypes:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .submitPost, .submitComment, .deletPost, .upVote, .flag, .downVote, .reportPost, .hidePost, .unhidePost:
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
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
            return "getAllPostsByTrending"
        case .hot:
            return "getAllPostsByHot"
        case .new:
            return "getAllPostsByNew"
        case .byUser:
            return "getAllPostsByUserId"
        case .byCategoryId:
            return "getPostsByCategoryId"
        }
    }
    
    var params: [String: Any] {
        switch self {
        case .byUser(let username):
            return ["userId" : username]
        default:
            return [:]
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
    
    func prepareParameters(_ type: DiscussionType) -> [String: Any] {
        var parameters: [String: Any] = [:]
        if let permlink = start_permlink {
            parameters["permlink"] = permlink
        }
        if let authorName = type.authorName ?? start_author {
            parameters[type.authorParamName] = authorName
        }
        if let categoryName = type.categoryName ?? tag {
            parameters[type.categoryParamName] = categoryName
        }
        parameters["limit"] = limit
        return parameters
    }
}
