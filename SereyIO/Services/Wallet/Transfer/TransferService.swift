//
//  TransferService.swift
//  SereyIO
//
//  Created by Panha Uy on 7/28/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxMoya
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
    
    func transferCoin(_ account: String, amount: Double, memo: String) -> Observable<TransferCoinModel> {
        let activeKey = WalletStore.shared.password(from: AuthData.shared.username ?? "") ?? ""
        let requestData = TransferCoinRequestModel(activeKey: activeKey, account: account, amount: amount, memo: memo).toJsonString() ?? ""
        let signTrxData = RSAUtils.encrypt(string: requestData, publicKey: self.publicKey)
        
        return provider.rx.requestObject(.transfer(signTrx: signTrxData ?? "", trxId: trxId), type: TransferCoinModel.self)
            .asObservable()
    }
    
    func powerUp(_ account: String, amount: Double) -> Observable<PowerUpModel> {
        let activeKey = WalletStore.shared.password(from: AuthData.shared.username ?? "") ?? ""
        let requestData = PowerUpRequestModel(activeKey: activeKey, account: account, amount: amount).toJsonString() ?? ""
        
        let signTrxData = RSAUtils.encrypt(string: requestData, publicKey: self.publicKey)
        
        return provider.rx.requestObject(.powerUp(signTrx: signTrxData ?? "", trxId: trxId), type: PowerUpModel.self)
            .asObservable()
    }
    
    func powerDown(amount: Double) -> Observable<PowerDownModel> {
        let activeKey = WalletStore.shared.password(from: AuthData.shared.username ?? "") ?? ""
        let requestData = PowerDownRequestModel(activeKey: activeKey, amount: amount).toJsonString() ?? ""
        
        let signTrxData = RSAUtils.encrypt(string: requestData, publicKey: self.publicKey)
        
        return provider.rx.requestObject(.powerDown(signTrx: signTrxData ?? "", trxId: trxId), type: PowerDownModel.self)
            .asObservable()
    }
    
    func claimReward() -> Observable<ClaimRewardModel> {
        let activeKey = WalletStore.shared.password(from: AuthData.shared.username ?? "")
        let data = "{ \"active_key\" : \"\(activeKey ?? "")\" }"
        let encryptedData = RSAUtils.encrypt(string: data, publicKey: self.publicKey)
        
        return provider.rx.requestObject(.claimRewardSerey(signTrx: encryptedData ?? "", trxId: trxId), type: ClaimRewardModel.self)
            .asObservable()
    }
    
    func cancelPower() -> Observable<CancelPowerModel> {
        let activeKey = WalletStore.shared.password(from: AuthData.shared.username ?? "") ?? ""
        let requestData = CancelPowerRequestModel(activeKey: activeKey).toJsonString() ?? ""
        
        let signTrxData = RSAUtils.encrypt(string: requestData, publicKey: self.publicKey)
        
        return provider.rx.requestObject(.cancelPowerDown(signTrx: signTrxData ?? "", trxId: trxId), type: CancelPowerModel.self)
            .asObservable()
    }
    
    func getAccountHistory() -> Observable<DataResponseModel<[TransactionModel]>> {
        return provider.rx.requestObject(.getAccountHistory, type: DataResponseModel<[TransactionModel]>.self)
            .asObservable()
    }
    
    func delegatePower(_ account: String, amount: Double) -> Observable<AnyCodable> {
        let activeKey = WalletStore.shared.password(from: AuthData.shared.username ?? "") ?? ""
        let requestData = DelegatePowerRequestModel(activeKey: activeKey, account: account, amount: amount).toJsonString() ?? ""
        
        let signTrxData = RSAUtils.encrypt(string: requestData, publicKey: self.publicKey)
        
        return provider.rx.requestObject(.delegatePower(signTrx: signTrxData ?? "", trxId: trxId), type: AnyCodable.self)
            .asObservable()
    }
}
