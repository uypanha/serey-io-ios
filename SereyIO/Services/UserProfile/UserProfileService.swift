//
//  UserProfileService.swift
//  SereyIO
//
//  Created by Mäd on 07/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import AnyCodable

class UserProfileService: AppService<UserProfileApi> {
    
    func getAllProfilePicture(_ username: String) -> Observable<[UserProfileModel]> {
        return self.provider.rx.requestObject(.getAllUserProfilePicture(username), type: [UserProfileModel].self)
            .asObservable()
    }
    
    func addUserProfile(_ url: String) -> Observable<UserProfileModel> {
        return self.provider.rx.requestObject(.addUserProfile(url), type: UserProfileModel.self)
            .asObservable()
    }
    
    func changeProfile(_ id: String) -> Observable<UserProfileModel> {
        return self.provider.rx.requestObject(.changeProfile(id), type: UserProfileModel.self)
            .asObservable()
    }
    
    func deleteProfle(id: String) -> Observable<[UserProfileModel]> {
        return self.provider.rx.requestObject(.deleteProfile(id), type: [UserProfileModel].self)
            .asObservable()
    }
}
