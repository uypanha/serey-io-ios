//
//  UserService.swift
//  SereyIO
//
//  Created by Panha Uy on 3/18/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import AnyCodable

class UserService: AppService<UserApi> {
    
    func fetchIpTrace() -> Observable<String?> {
        return self.provider.rx.request(.iPTrace)
            .asObservable()
            .map { String(data: $0.data, encoding: .utf8) }
    }
    
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
    
    func changePassword(_ current: String, _ new: String) -> Observable<AnyCodable> {
        return self.provider.rx.requestObject(.changePassword(current: current, new: new), type: AnyCodable.self)
            .asObservable()
    }
}
