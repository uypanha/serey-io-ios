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
    let profileImage: BehaviorRelay<UserProfileModel?>
    
    var userService: UserService
    let userProfileService: UserProfileService
    let fileUploadService: FileUploadService
    
    let isUploading: BehaviorRelay<Bool>
    
    init(_ username: String) {
        self.username = .init(value: username)
        self.profileImage = .init(value: nil)
        
        self.userService = .init()
        self.userProfileService = .init()
        self.fileUploadService = .init()
        self.isUploading = .init(value: false)
        super.init()
        
        let predicate = NSPredicate(format: "active == true AND username == %@", username)
        let defaultImage: UserProfileModel? = UserProfileModel().qeuryFirst(by: predicate)
        self.profileImage.accept(defaultImage)
    }
    
    func refreshScreen() {
    }
}

// MARK: - Networks
extension BaseUserProfileViewModel {
    
    func getAllUserProfilePicture(_ username: String) {
        self.userProfileService.getAllProfilePicture(username)
            .subscribe(onNext: { [weak self] profiles in
                profiles.saveAll()
                self?.profileImage.accept(profiles.first(where: { $0.active }))
                self?.refreshScreen()
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
    
    func changeProfile(_ id: String) {
        self.userProfileService.changeProfile(id)
            .subscribe(onNext: { [unowned self] data in
                self.isUploading.accept(false)
                self.profileImage.accept(data)
                self.getAllUserProfilePicture(self.username.value)
            }, onError: { [weak self] error in
                self?.isUploading.accept(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}
