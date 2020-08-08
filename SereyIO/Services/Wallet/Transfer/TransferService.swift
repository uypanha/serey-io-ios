//
//  TransferService.swift
//  SereyIO
//
//  Created by Panha Uy on 7/28/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import AnyCodable

class TransferService: AppService<TransferApi> {
    
    var publicKey: String = ""
    var trxId: Int = 0
    
    func initTransaction() -> Observable<InitTransactionModel> {
        return provider.rx.requestObject(.initTransaction, type: DataResponseModel<InitTransactionModel>.self)
            .asObservable()
            .map { $0.data }
    }
    
    func transferCoin(_ account: String, amount: String, memo: String) -> Observable<TransferCoinModel> {
        let activeKey = WalletStore.shared.password(from: AuthData.shared.username ?? "") ?? ""
        let requestData = TransferCoinRequestModel(activeKey: activeKey, account: account, amount: amount, memo: memo).toJsonString() ?? ""
        let signTrxData = RSAUtils.encrypt(string: requestData, publicKey: self.publicKey)
        
        return provider.rx.requestObject(.transfer(signTrx: signTrxData ?? "", trxId: trxId), type: TransferCoinModel.self)
            .asObservable()
    }
    
    func claimReward() -> Observable<ClaimRewardModel> {
        let activeKey = WalletStore.shared.password(from: AuthData.shared.username ?? "")
        let data = "{ \"active_key\" : \"\(activeKey ?? "")\" }"
        let encryptedData = RSAUtils.encrypt(string: data, publicKey: self.publicKey)
        
        return provider.rx.requestObject(.claimRewardSerey(signTrx: encryptedData ?? "", trxId: trxId), type: ClaimRewardModel.self)
            .asObservable()
    }
    
    func getAccountHistory() -> Observable<[TransactionModel]> {
        return provider.rx.requestObject(.getAccountHistory, type: [TransactionModel].self)
            .asObservable()
    }
}