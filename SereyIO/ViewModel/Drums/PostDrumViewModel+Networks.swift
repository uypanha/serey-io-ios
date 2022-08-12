//
//  PostDrumViewModel+Networks.swift
//  SereyIO
//
//  Created by Panha Uy on 8/8/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

extension PostDrumViewModel {
    
    func submitDrumPost() {
        self.drumService.submitDrum(self.prepareSubmitModel())
            .subscribe(onNext: { [weak self] data in
                self?.isUploading.accept(false)
                DispatchQueue.main.async {
                    self?.handlePostSubmitted()
                }
            }, onError: { [weak self] error in
                self?.isUploading.accept(false)
                self?.shouldPresentError(ErrorHelper.prepareError(error: error))
            }) ~ self.disposeBag
    }
    
    internal func uploadPhotos(faildCompletion: @escaping (Bool) -> Void) {
        self.pickerModels.value.filter { $0.uploadedUrl == nil }.forEach { pickerFileModel in
            self.uploadPhoto(pickerFileModel, faildCompletion: faildCompletion)
        }
    }
    
    private func uploadPhoto(_ pickerFileModel: PickerFileModel, faildCompletion: @escaping (Bool) -> Void) {
        pickerFileModel.isUploading.accept(true)
        self.fileUploadService.uploadPickerFile(pickerFileModel)
            .subscribe(onNext: { [weak self] fileUploadModel in
                pickerFileModel.uploadedUrl = fileUploadModel.url
                pickerFileModel.isUploading.accept(false)
                self?.validateUploadedUrls()
            }, onError: { error in
                pickerFileModel.isUploading.accept(false)
                faildCompletion(true)
            }) ~ self.disposeBag
    }
    
    fileprivate func validateUploadedUrls() {
        let uploadedUrls = self.pickerModels.value.map { $0.uploadedUrl }
        if !uploadedUrls.contains(where: { $0 == nil }) {
            // All of images are ready uploaded
            self.submitDrumPost()
        }
    }
    
    fileprivate func prepareSubmitModel() -> SubmitDrumPostModel {
        let images: [String] = self.pickerModels.value.map { $0.uploadedUrl }.filter { $0 != nil }.map { $0! }
        let title = self.descriptionTextField.value ?? ""
        let body = self.descriptionTextField.value ?? ""
        return .init(title: title, body: body, images: images)
    }
    
    func handlePostSubmitted() {
        //        if self.post.value != nil {
        //            // must be updated post
        //            fetchPostDetial()
        //        } else {
        NotificationDispatcher.sharedInstance.dispatch(.drumCreated)
        self.shouldPresent(.dismiss)
        //            if let draft = self.draft.value {
        //                RealmManager.delete(draft)
        //            }
        //        }
    }
}
