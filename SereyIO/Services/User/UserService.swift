//
//  UserService.swift
//  SereyIO
//
//  Created by Panha Uy on 3/18/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class UserService: AppService<UserApi> {
    
    func fetchProfile(_ username: String) -> Observable<DataResponseModel<AccountModel>> {
        return self.provider.rx.requestObject(.profile(userName: username), type: DataResponseModel<AccountModel>.self)
            .asObservable()
    }
}
