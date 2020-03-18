//
//  AuthService.swift
//  SereyIO
//
//  Created by Panha Uy on 3/15/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class AuthService: AppService<AuthApi> {
    
    func signIn(_ userName: String, _ privateKey: String) -> Observable<DataResponseModel<TokenModel>> {
        return self.provider.rx.requestObject(.login(userName: userName, password: privateKey), type: DataResponseModel<TokenModel>.self)
            .asObservable()
    }
}
