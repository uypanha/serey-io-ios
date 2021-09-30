//
//  NotificationApi.swift
//  SereyIO
//
//  Created by Panha Uy on 9/27/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation
import Moya

enum NotificationApi {
    
    case notifications(PaginationRequestModel)
    
    case updateRead(String)
}

extension NotificationApi: AuthorizedApiTargetType {
    var parameters: [String : Any] {
        switch self {
        case .notifications(let pageModel):
            return pageModel.parameters
        default:
            return [:]
        }
    }
    
    var path: String {
        switch self {
        case .notifications:
            return "/api/v1/notification/get_all_by_user"
        case .updateRead(let id):
            return "/api/v1/notification/update_read/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .notifications:
            return .get
        case .updateRead:
            return .put
        }
    }
    
    var task: Task {
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
