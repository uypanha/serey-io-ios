//
//  AuthService.swift
//  SereyIO
//
//  Created by Panha Uy on 3/15/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import AnyCodable

class AuthService: AppService<AuthApi> {
    
    func signIn(_ userName: String, _ privateKey: String) -> Observable<DataResponseModel<TokenModel>> {
        return self.provider.rx.requestObject(.login(userName: userName, password: privateKey), type: DataResponseModel<TokenModel>.self)
            .asObservable()
    }
    
    func loginOwner(_ username: String, _ ownerKey: String) -> Observable<DataResponseModel<TokenModel>> {
        return self.provider.rx.requestObject(.login(userName: username, password: ownerKey), type: DataResponseModel<TokenModel>.self)
            .asObservable()
    }
    
    func checkUsernane(username: String, publicKey: String) -> Observable<DataResponseModel<TokenModel>> {
        return self.provider.rx.requestObject(.checkUsername(username: username, publicKey: publicKey), type: DataResponseModel<TokenModel>.self)
            .asObservable()
    }
    
    func signUpWallet(username: String, postingPriKey: String, password: String, requestToken: String) -> Observable<SignUpWalletModel> {
        return self.provider.rx.requestObject(.signUpWallet(username: username, postingPriKey: postingPriKey, password: password, requestToken: requestToken), type: SignUpWalletModel.self)
            .asObservable()
    }
}
