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
    
    func claimReward() -> Observable<ClaimRewardModel> {
        let activeKey = WalletStore.shared.password(from: AuthData.shared.username ?? "")
        let data = "{ \"active_key\" : \"\(activeKey ?? "")\" }"
        let encryptedData = RSAUtils.encryptWithRSAPublicKey(data.data(using: .utf8)!, pubkeyBase64: self.publicKey, keychainTag: "")
        let base64DataText = encryptedData?.base64EncodedString(options: NSData.Base64EncodingOptions()) ?? ""
        
        return provider.rx.requestObject(.claimRewardSerey(signTrx: base64DataText, trxId: trxId), type: ClaimRewardModel.self)
            .asObservable()
    }
}
