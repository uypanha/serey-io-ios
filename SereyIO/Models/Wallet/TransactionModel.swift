//
//  TransactionModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

struct TransactionModel: Codable {
    
    var trxId: String?
    var timestamp: String?
    var opData: OpModel
    
    var createDateString: String? {
        get {
            guard let date = Date.date(from: self.timestamp ?? "", format: "yyyy-MM-dd'T'HH:mm:ss") else { return nil }
            
            return date.format("HH:mm, yyy.MM.dd")
        }
    }
    
    var typeImage: UIImage? {
        return opData.opType?.image(from: opData.data.from)
    }
    
    var typeTitle: String? {
        return opData.opType?.title(from: opData.data.from)
    }
    
    var value: String? {
        return opData.opType?.preapreValue(opData.data)
    }
    
    var valueColor: UIColor? {
        return opData.opType?.valueColor(username: opData.data.from)
    }
    
    enum CodingKeys: String, CodingKey {
        case trxId = "trx_id"
        case timestamp
        case opData = "op"
    }
}

struct OpModel: Codable {
    
    var type: String
    var data: TransactionDataModel
    
    var opType: TransferType? {
        return TransferType(rawValue: type)
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case data
    }
}

struct TransactionDataModel: Codable {
    
    var account: String?
    var rewardSteem: String?
    var rewardVests: String?
    
    var from: String?
    var to: String?
    var amount: String?
    var memo: String?
    
    enum CodingKeys: String, CodingKey {
        case account
        case rewardSteem = "reward_steem"
        case rewardVests = "reward_vests"
        case from
        case to
        case amount
        case memo
    }
}

enum TransferType: String {
    case transfer = "transfer"
    case transferVesting = "transfer_to_vesting"
    case claimRewardBalance = "claim_reward_balance"
    
    func image(from username: String?) -> UIImage? {
        switch self {
        case .transfer:
            return username == AuthData.shared.username ? R.image.transactionTransfer() : R.image.transactionReceive()
        case .claimRewardBalance:
            return R.image.transactionClaimReward()
        case .transferVesting:
            return R.image.transactionPowerUp()
        }
    }
    
    func title(from username: String?) -> String {
        switch self {
        case .transfer:
            return username == AuthData.shared.username ? "Transfered" : "Received"
        case .claimRewardBalance:
            return "Claim Reward"
        case .transferVesting:
            return "Power Up"
        }
    }
    
    func preapreValue(_ data: TransactionDataModel) -> String {
        switch self {
        case .transfer:
            return data.from == AuthData.shared.username ? "-\(data.amount ?? "")" : "+\(data.amount ?? "")"
        case .claimRewardBalance:
            return "Claim Reward"
        case .transferVesting:
            return data.amount ?? ""
        }
    }
    
    func valueColor(username: String?) -> UIColor {
        switch self {
        case .transfer:
            return username == AuthData.shared.username ? .red : ColorName.primary.color
        default:
            return .darkGray
        }
    }
}
