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
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .submitDrum:
            return .post
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .allDrums, .drumDetail:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .submitDrum:
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
