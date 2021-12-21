//
//  CoinApi.swift
//  SereyMarket
//
//  Created by Panha Uy on 5/7/21.
//  Copyright © 2021 Serey Marketplace. All rights reserved.
//

import Foundation
import Moya

enum CoinApi {
    
    case ticker
}

extension CoinApi: AuthorizedApiTargetType {
    
    var parameters: [String : Any] {
        return [:]
    }
    
    var path: String {
        switch self {
        case .ticker:
            return "/api/v1/general/get_serey_price"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
