//
//  MediaPickerHelper.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Photos
import AVFoundation
import DKImagePickerController

class MediaPickerHelper: NSObject {
    
    lazy var disposeBag = DisposeBag()
    
    var selectedPhotoSubject = PublishSubject<[PickerFileModel]>()
    
    private weak var presentingViewController: UIViewController!
    private var _pickerController: DKImagePickerController?
    private var pickerController: DKImagePickerController? {
        get {
            self.preparePicker()
            return self._pickerController
        }
        set {
            self._pickerController = newValue
        }
    }
    
    /// Forces deselect of previous selected image. allowSwipeToSelect will be ignored.
    public var singleSelect = true
    public var selectedAssets: [DKAsset] = []
    /// The maximum count of assets which the user will be able to select, a value of 0 means no limit.
    public var maximumSelectCouont: Int = 0
    
    private var includeVideo: Bool = false
    
    init(withPresenting viewController: UIViewController, includeVideo: Bool = false) {
        self.includeVideo = includeVideo
        self.presentingViewController = viewController
    }
    
    func preparePicker() {
        let dkImagePickerController = DKImagePickerController()
        dkImagePickerController.singleSelect = singleSelect
        dkImagePickerController.showsCancelButton = true
        
        dkImagePickerController.didSelectAssets = { [weak self] (assets: [DKAsset]) in
            self?.didSelectAssets(assets)
        }
        
        pickerController = dkImagePickerController
    }
    
    func showImagePickerAlert(title: String? = nil, additional actionSheets: [UIViewController.ActionSheet]? = nil, completion: @escaping ((_ index: Int, _ action: UIViewController.ActionSheet) -> Void) = {_,_ in }) {

        var photoActionSheets: [UIViewController.ActionSheet] = [
            UIViewController.ActionSheet(title: R.string.common.takePhoto.localized(), style: .default),
            UIViewController.ActionSheet(title: R.string.common.choosePhoto.localized(), style: .default)
        ]

        actionSheets?.forEach({ (actionSheet) in
            photoActionSheets.append(actionSheet)
        })

        self.presentingViewController.showActionSheet(title: title ?? "Choose Image Source", actionSheets: photoActionSheets) { (index: Int, action: UIViewController.ActionSheet) in

            switch(index) {
            case 0:
                // Take Photo
                self.showCameraPicker()
            case 1:
                // Choose Photo
                self.showImagePicker()
            default:
                completion(index, action)
            }
            print("Index: \(index) ; Action: \(action.title)")
        }
    }
    
    func showImagePicker() {
        guard let pickerController = self.pickerController else {
            return
        }
        
        pickerController.maxSelectableCount = maximumSelectCouont
        pickerController.setSelectedAssets(assets: self.selectedAssets)
        pickerController.sourceType = .photo
        pickerController.assetType = includeVideo ? .allAssets : .allPhotos
        pickerController.modalPresentationStyle = .fullScreen

        self.presentingViewController.present(pickerController, animated: true, completion: nil)
    }
    
    func showCameraPicker() {
        guard let pickerController = self.pickerController else {
            return
        }
        pickerController.sourceType = .camera
        pickerController.assetType = includeVideo ? .allAssets : .allPhotos
        pickerController.modalPresentationStyle = .fullScreen
        self.presentingViewController.present(pickerController, animated: true, completion: nil)
    }
}

// MARK: - Handlers
extension MediaPickerHelper {
    
    private func didSelectAssets(_ assets: [DKAsset]) {
        var pickedPhotos: [PickerFileModel] = []
        for asset in assets {
            pickedPhotos.append(.init(asset))
        }
        
        if !pickedPhotos.isEmpty { self.selectedPhotoSubject.onNext(pickedPhotos) }
        pickerController = nil
    }
}

class PickerPhotoModel: Equatable {
    
    var image: UIImage
    var localIdentifier: String?
    var orginalSize: CGSize
    var isUploading: BehaviorRelay<Bool>
    
    init(_ image: UIImage, localIdentifier: String?, orginalSize: CGSize, isUploading: BehaviorRelay<Bool> = BehaviorRelay(value: false)) {
        self.image = image
        self.localIdentifier = localIdentifier
        self.orginalSize = orginalSize
        self.isUploading = isUploading
    }
    
    static func == (lhs: PickerPhotoModel, rhs: PickerPhotoModel) -> Bool {
        return true
    }
}
