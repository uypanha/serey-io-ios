//
//  TransferApi.swift
//  SereyIO
//
//  Created by Panha Uy on 7/28/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import Moya

enum TransferApi {
    
    case initTransaction
    
    case claimRewardSerey(signTrx: String, trxId: Int)
    
    case transfer(signTrx: String, trxId: Int)
    
    case powerUp(signTrx: String, trxId: Int)
    
    case powerDown(signTrx: String, trxId: Int)
    
    case getAccountHistory
    
    case cancelPowerDown(signTrx: String, trxId: Int)
}

extension TransferApi: AuthorizedApiTargetType {
    
    var parameters: [String : Any] {
        switch self {
        case .initTransaction:
            return [:]
        case .claimRewardSerey(let signTrx, let trxId):
            return [
                "trx_type"  : "claimRewards",
                "trxId"     : trxId,
                "signTrx"   : signTrx
            ]
        case .transfer(let signTrx, let trxId):
            return [
                "trx_type"  : "Transfer",
                "trxId"     : trxId,
                "signTrx"   : signTrx
            ]
        case .powerUp(let signTrx, let trxId):
            return [
                "trx_type"  : "powerUp",
                "trxId"     : trxId,
                "signTrx"   : signTrx
            ]
        case .powerDown(let signTrx, let trxId):
            return [
                "trx_type"  : "powerDown",
                "trxId"     : trxId,
                "signTrx"   : signTrx
            ]
        case .cancelPowerDown(let signTrx, let trxId):
            return [
                "trx_type"  : "cancelPower",
                "trxId"     : trxId,
                "signTrx"   : signTrx
            ]
        default:
            return [:]
        }
    }
    
    var path: String {
        switch self {
        case .initTransaction:
            return "/api/v1/transfer/initTransaction"
        case .claimRewardSerey:
            return "/api/v1/transfer/claimRewardsSerey"
        case .transfer:
            return "/api/v1/transfer/transferSereyCoin"
        case .getAccountHistory:
            return "/api/v1/transfer/getAccountHistory"
        case .powerUp:
            return "/api/v1/transfer/powerUpSerey"
        case .powerDown:
            return "/api/v1/transfer/powerDownSerey"
        case .cancelPowerDown:
            return "/api/v1/transfer/cancelPowerSerey"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
