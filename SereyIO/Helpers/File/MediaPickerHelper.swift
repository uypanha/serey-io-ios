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

class MediaPickerHelper: NSObject {
    
    var selectedPhotoSubject = PublishSubject<PickerPhotoModel>()
    
    private weak var presentingViewController: UIViewController!
    private var _pickerController: UIImagePickerController?
    private var pickerController: UIImagePickerController? {
        get {
            if self._pickerController == nil {
                self.preparePicker()
            }
            
            return self._pickerController
        }
        set {
            self._pickerController = newValue
        }
    }
    
    public var allowEditting = true
    private var imagePickerControllerImage: UIImagePickerController.InfoKey {
        get {
            if (self.allowEditting) {
                return UIImagePickerController.InfoKey.editedImage
            }
            
            return UIImagePickerController.InfoKey.originalImage
        }
    }
    
    init(withPresenting viewController: UIViewController, allowEditting: Bool = true) {
        self.allowEditting = allowEditting
        self.presentingViewController = viewController
    }
    
    func preparePicker() {
        let picker = UIImagePickerController()
        picker.allowsEditing = self.allowEditting
        picker.delegate = self
        
        self.pickerController = picker
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
        pickerController.sourceType = .photoLibrary
        pickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)!
        pickerController.modalPresentationStyle = .fullScreen
        
        self.presentingViewController.present(pickerController, animated: true, completion: nil)
    }
    
    func showCameraPicker() {
        guard let pickerController = self.pickerController else {
            return
        }
        pickerController.sourceType = .camera
        self.presentingViewController.present(pickerController, animated: true, completion: nil)
    }
}

extension MediaPickerHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.presentingViewController.dismiss(animated: true, completion: {
            self.pickerController = nil
        })
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let chosenImage = info[self.imagePickerControllerImage] as? UIImage else {
            self.presentingViewController.dismiss(animated: true, completion: {
                self.pickerController = nil
            })
            return
        }
        
        self.selectedPhotoSubject.onNext(PickerPhotoModel(chosenImage, localIdentifier: chosenImage.accessibilityIdentifier, orginalSize: chosenImage.size))
        self.presentingViewController.dismiss(animated: true, completion: {
            self.pickerController = nil
        })
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
