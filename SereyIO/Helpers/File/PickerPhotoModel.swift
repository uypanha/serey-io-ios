//
//  PickerPhotoModel.swift
//  SereyIO
//
//  Created by Panha Uy on 5/8/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import DKImagePickerController
import RxSwift
import RxCocoa
import RxRelay
import Photos
import RxBinding

class PickerFileModel: Equatable, Hashable {
    
    lazy var disposeBag = DisposeBag()
    
    let dkAsset: DKAsset
    let localIdentifier: String?
    let filename: String?
    let fileSize: UInt
    let orginalSize: CGSize
    var uploadedUrl: String? = nil
    
    let isUploading: BehaviorRelay<Bool>
    let uploadProgress: BehaviorRelay<Double>
    
    let previewImage: BehaviorRelay<UIImage?>
    
    var isLocalPhoto: Bool {
        return localIdentifier != nil
    }
    
    var filenameWithoutExtension: String? {
        if let filename = self.filename?.split(separator: ".").first {
            return String(filename)
        }
        return filename
    }
    
    init(_ asset: DKAsset, isUploading: BehaviorRelay<Bool> = .init(value: false)) {
        self.dkAsset = asset
        self.localIdentifier = asset.localIdentifier
        self.filename = asset.fileName
        self.fileSize = asset.fileSize
        self.orginalSize = .init(width: asset.originalAsset?.pixelWidth ?? 0, height: asset.originalAsset?.pixelHeight ?? 0)
        self.isUploading = isUploading
        self.uploadProgress = .init(value: 0.0)
        self.previewImage = .init(value: nil)
        
        self.mediaFromLibrary(with: .init(width: 200, height: 200))
            .subscribe(onNext: { [weak self] media in
                self?.previewImage.accept(media.image)
            }) ~ self.disposeBag
    }
    
    static func == (lhs: PickerFileModel, rhs: PickerFileModel) -> Bool {
        return lhs.localIdentifier == rhs.localIdentifier
    }
    
    var hashValue: Int {
        return localIdentifier?.hashValue ?? 0
    }
    
    func hash(into hasher: inout Hasher) {}
}

// MAKR: - Tools
extension PickerFileModel {
    
    func fetchAsset() -> PHAsset? {
        guard let localIdentifier = localIdentifier else { return nil }
        let savedAssets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        guard let asset = savedAssets.firstObject else { return nil }
        return asset
    }
    
    func editImageFromLibary(with viewController: UIViewController) -> Observable<AssetUploadModel> {
        return mediaFromLibrary()
    }
    
    func mediaFromLibrary(with size: CGSize? = nil) -> Observable<AssetUploadModel> {
        guard let asset = fetchAsset() else { return Observable.error(NSError(domain: "", code: 1, userInfo: nil)) }
        
        if asset.mediaType == .image {
            return fetchImageFromAsset(asset, withSize: size ?? self.orginalSize)
        } else {
            return fetchVideoFromAsset(asset)
        }
    }
    
    fileprivate func fetchImageFromAsset(_ asset: PHAsset, withSize size: CGSize) -> Observable<AssetUploadModel> {
        let publishSubject = PublishSubject<AssetUploadModel>()
        
        let phImageRequestOptions = PHImageRequestOptions()
        phImageRequestOptions.isSynchronous = false
        phImageRequestOptions.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: phImageRequestOptions) { (image, info) in
            let imageName = "\(asset.value(forKey: "filename") ?? "unknown")"
            publishSubject.onNext(AssetUploadModel(image, imageName: imageName))
        }
        
        return publishSubject
    }
    
    fileprivate func fetchVideoFromAsset(_ asset: PHAsset) -> Observable<AssetUploadModel> {
        let publishSubject = PublishSubject<AssetUploadModel>()
        
        let phVideoRequestOption = PHVideoRequestOptions()
        phVideoRequestOption.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: phVideoRequestOption) { (avAsset, audioMix, info) in
            publishSubject.onNext(AssetUploadModel((avAsset as? AVURLAsset)?.url))
        }
        
        return publishSubject
    }
}

// MAKR: - AssetUploadModel
class AssetUploadModel {
    
    var image: UIImage? = nil
    var url: URL? = nil
    var filename: String? = nil
    
    var filenameUrlEncoded: String {
        return (filename ?? url?.lastPathComponent)?.stringByAddingPercentEncodingForRFC3986() ?? ""
    }
    
    init(_ image: UIImage?, imageName: String?) {
        self.image = image
        self.filename = imageName
    }
    
    init(_ url: URL?, filename: String? = nil) {
        self.url = url
        self.filename = filename ?? url?.lastPathComponent
    }
}

// MAKR: - AssetUploadModel Extentions
extension AssetUploadModel {
    
    var filenameWithoutExtension: String? {
        if let filename = self.filename?.split(separator: ".").first {
            return String(filename)
        }
        return filename
    }
    
    var imageSize: CGSize {
        get {
            return self.image?.size ?? CGSize.zero
        }
    }
    
    var isImage: Bool {
        get {
            return self.image != nil
        }
    }
    
    var isVideo: Bool {
        get {
            return self.mimeType.starts(with: "video")
        }
    }
    
    var isPreviewable: Bool {
        get {
            return self.isImage
        }
    }

    var fileSize: Int64 {
        get {
            if let url = self.url {
                return UtilsHelper.fileSize(from: url)
            } else if let image = self.image {
                return UtilsHelper.fileSize(from: image)
            }
            return 0
        }
    }
    
    var fileSizeReadable: String {
        return Units(bytes: self.fileSize).getReadableUnit()
    }

    var mimeType: String {
        get {
            if let url = self.url {
                return url.mimeType
            } else if let image = self.image {
                return UtilsHelper.mimeType(from: image)
            }
            return DEFAULT_MIME_TYPE
        }
    }
    
    var representImage: UIImage? {
        if self.isImage {
            return nil
        } else if isVideo {
            return UIImage(named: "video")
        } else if let extenion = self.url?.pathExtension {
            return UIImage(named: extenion) ?? UIImage(named: "unknown")
        }
        return UIImage(named: "unknown")
    }
}

