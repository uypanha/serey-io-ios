//
//  DrumsApi.swift
//  SereyIO
//
//  Created by Panha Uy on 30/6/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import Moya

enum DrumsApi {
    
    case allDrums(String?, PaginationRequestModel)
    
    case drumDetail(String, String)
    
    case submitDrum(SubmitDrumPostModel)
    
    case redrum(author: String, permlink: String)
    
    case undoRedrum(author: String, permlink: String)
    
    case submitQuoteDrum(SubmitQuoteDrumModel)
}

extension DrumsApi: AuthorizedApiTargetType {
    
    var parameters: [String : Any] {
        switch self {
        case .allDrums(let author, let pagination):
            var parameters = pagination.parameters
            if let author = author {
                parameters["author"] = author
            }
            return parameters
        case .drumDetail(let author, let permlink):
            return [
                "permlink" : permlink,
                "authorName" : author
            ]
        case .submitDrum(let model):
            var parameters = model.parameters
            if let country = PreferenceStore.shared.currentCountry {
                parameters["country_name"] = country.countryName
            }
            return parameters
        case .redrum(let author, let permlink):
            return [
                "permlink" : permlink,
                "author" : author
            ]
        case .undoRedrum(let author, let permlink):
            return [
                "permlink" : permlink,
                "author" : author
            ]
        case .submitQuoteDrum(let model):
            return model.parameters
        }
    }
    
    var path: String {
        switch self {
        case .allDrums(let author, _):
            if author != nil {
                return "/api/v1/sereyweb/get_all_drum_posts_by_author"
            }
            return "/api/v1/sereyweb/get_all_drum_posts"
        case .drumDetail:
            return "/api/v1/sereyweb/get_drum_detail_by_permlink"
        case .submitDrum:
            return "/api/v1/sereyweb/submitPost"
        case .redrum:
            return "/api/v1/general/redrum_post"
        case .undoRedrum:
            return "/api/v1/general/undo_redrum_post"
        case .submitQuoteDrum:
            return "/api/v1/sereyweb/submit_quote_drum"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .submitDrum, .redrum, .undoRedrum, .submitQuoteDrum:
            return .post
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .allDrums, .drumDetail:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .submitDrum, .redrum, .undoRedrum, .submitQuoteDrum:
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .redrum, .undoRedrum:
            return [
                "token" : AuthData.shared.userToken ?? ""
            ]
        default:
            return [:]
        }
    }
}
