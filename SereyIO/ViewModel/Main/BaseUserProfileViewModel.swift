//
//  BaseUserProfileViewModel.swift
//  SereyIO
//
//  Created by Mäd on 13/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class BaseUserProfileViewModel: BaseCellViewModel {
    
    let username:  BehaviorRelay<String>
    let loggedUserInfo: BehaviorRelay<UserModel?>
    let userInfo: BehaviorRelay<UserModel?>
    
    var userService: UserService
    let userProfileService: UserProfileService
    let fileUploadService: FileUploadService
    
    let isUploading: BehaviorRelay<Bool>
    
    init(_ username: String) {
        self.username = .init(value: username)
        self.userInfo = .init(value: nil)
        self.loggedUserInfo = .init(value: AuthData.shared.loggedUserModel)
        
        self.userService = .init()
        self.userProfileService = .init()
        self.fileUploadService = .init()
        self.isUploading = .init(value: false)
        super.init()
    }
    
    func refreshScreen() {
    }
}

// MARK: - Networks
extension BaseUserProfileViewModel {
    
    func getAllUserProfilePicture(completion: @escaping ([UserProfileModel]) -> Void) {
        self.userProfileService.getAllProfilePicture(self.username.value)
            .subscribe(onNext: { [weak self] profiles in
                completion(profiles)
                self?.refreshScreen()
            }, onError: { [weak self] error in
                completion([])
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    func fetchProfile() {
        self.userService.fetchProfile(self.username.value)
            .subscribe(onNext: { data in
                if data.data.result.name == AuthData.shared.username {
                    data.data.result.save()
                }
                self.userInfo.accept(data.data.result)
            }) ~ self.disposeBag
    }
    
    func uploadPhoto(_ pickerModel: PickerPhotoModel) {
        self.isUploading.accept(true)
        self.fileUploadService.uploadPhoto(pickerModel.image)
            .subscribe(onNext: { [weak self] fileUpload in
                self?.addProfile(fileUpload.url)
            }, onError: { [weak self] error in
                self?.isUploading.accept(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    func addProfile(_ url: String) {
        self.userProfileService.addUserProfile(url)
            .subscribe(onNext: { [weak self] data in
                self?.changeProfile(data.id)
            }, onError: { [weak self] error in
                self?.isUploading.accept(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    func changeProfile(_ id: String, completion: @escaping (UserProfileModel) -> Void = { _ in }) {
        self.userProfileService.changeProfile(id)
            .subscribe(onNext: { [unowned self] data in
                self.isUploading.accept(false)
                self.fetchProfile()
                completion(data)
            }, onError: { [weak self] error in
                self?.isUploading.accept(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}
