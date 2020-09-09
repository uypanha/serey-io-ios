//
//  TransactionModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

struct TransactionModel: Codable {
    
    var opData: OpModel
    
    var createDateString: String? {
        get {
            guard let date = Date.date(from: self.opData.timestamp ?? "", format: "yyyy-MM-dd'T'HH:mm:ss") else { return nil }
            
            return date.format("HH:mm, yyy.MM.dd")
        }
    }
    
    var typeImage: UIImage? {
        return opData.opType?.image(opData.data)
    }
    
    var typeTitle: String? {
        return opData.opType?.title(opData.data)
    }
    
    var value: String? {
        return opData.opType?.preapreValue(opData.data)
    }
    
    var valueColor: UIColor? {
        return opData.opType?.valueColor(opData.data)
    }
    
    var infoCells: [CellViewModel] {
        return opData.opType?.prepareInfoCells(opData.data) ?? []
    }
    
    enum CodingKeys: String, CodingKey {
        case opData = "op"
    }
}

struct OpModel: Codable {
    
    var trxId: String?
    var timestamp: String?
    var type: String
    var data: TransactionDataModel
    
    var opType: TransferType? {
        return TransferType(rawValue: type)
    }
    
    enum CodingKeys: String, CodingKey {
        case trxId = "trx_id"
        case type
        case data
        case timestamp
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
    
    var vestingShares: String?
    
    enum CodingKeys: String, CodingKey {
        case account
        case rewardSteem = "reward_steem"
        case rewardVests = "reward_vests"
        case from
        case to
        case amount
        case memo
        case vestingShares = "vesting_shares"
    }
}

enum TransferType: String {
    case transfer = "transfer"
    case transferVesting = "transfer_to_vesting"
    case claimRewardBalance = "claim_reward_balance"
    case withdrawVesting = "withdraw_vesting"
    
    func image(_ data: TransactionDataModel) -> UIImage? {
        switch self {
        case .transfer:
            return data.from == AuthData.shared.username ? R.image.transactionTransfer() : R.image.transactionReceive()
        case .claimRewardBalance:
            return R.image.transactionClaimReward()
        case .transferVesting:
            return R.image.transactionPowerUp()
        case .withdrawVesting:
            return data.vestingShares == "0.000000 VESTS" ? R.image.transactionCancelPowerDown() : R.image.transactionPowerDown()
        }
    }
    
    func title(_ data: TransactionDataModel) -> String {
        switch self {
        case .transfer:
            return data.from == AuthData.shared.username ? "Transfered" : "Received"
        case .claimRewardBalance:
            return "Claim Reward"
        case .transferVesting:
            return "Power Up"
        case .withdrawVesting:
            return data.vestingShares == "0.000000 VESTS" ? "Cancel Power" : "Power Down"
        }
    }
    
    func preapreValue(_ data: TransactionDataModel) -> String {
        switch self {
        case .transfer:
            return data.from == AuthData.shared.username ? "-\(data.amount ?? "")" : "+\(data.amount ?? "")"
        case .claimRewardBalance:
            return "+" + (data.rewardVests ?? "0 SEREY")
        case .transferVesting:
            return "+" + (data.amount ?? "")
        case .withdrawVesting:
            return data.vestingShares == "0.000000 VESTS" ? (data.vestingShares ?? "") : "+\(data.vestingShares ?? "")"
        }
    }
    
    func valueColor(_ data: TransactionDataModel) -> UIColor {
        switch self {
        case .transfer:
            return data.from == AuthData.shared.username ? .red : ColorName.primary.color
        case .claimRewardBalance, .transferVesting:
            return ColorName.primary.color
        case .withdrawVesting:
            return data.vestingShares == "0.000000 VESTS" ? .darkGray : ColorName.primary.color
        }
    }
    
    func prepareInfoCells(_ data: TransactionDataModel) -> [CellViewModel] {
        let titleCell = TextCellViewModel(with: self.prepareCellTitle(data), properties: .init(font: .boldSystemFont(ofSize: 17), textColor: .black), indicatorAccessory: false)
        return [titleCell]
    }
    
    func prepareCellTitle(_ data: TransactionDataModel) -> String {
        switch self {
        case .transfer:
            return data.from == AuthData.shared.username ? "Received from \(data.from!)" : "Transfered to \(data.to!)"
        case .claimRewardBalance:
            return "Claim Reward"
        case .transferVesting:
            return "Power Up"
        case .withdrawVesting:
            return data.vestingShares == "0.000000 VESTS" ? "Cancel Power" : "Power Down"
        }
    }
}
