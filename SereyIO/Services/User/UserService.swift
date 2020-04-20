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
    
    func getFollowerList(_ username: String) -> Observable<FollowerListResponse> {
        return self.provider.rx.requestObject(.getFollowerList(author: username), type: FollowerListResponse.self)
            .asObservable()
    }
    
    func followAction(_ username: String, action: FollowActionType) -> Observable<FollowActionModel> {
        return self.provider.rx.requestObject(.followAction(author: username, actionType: action), type: FollowActionModel.self)
            .asObservable()
    }
}
