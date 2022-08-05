//
//  FileUploadService.swift
//  SereyIO
//
//  Created by Panha Uy on 3/31/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire

/// An `Error` emitted by `FileUploadService`.
public enum FileUploadError: Error {
    /// Large file error were encountered.
    case fileUploadError(String)
    case error(Error)
}

class FileUploadService {
    
    var disposeBag: DisposeBag
    
    init() {
        self.disposeBag = DisposeBag()
    }
    
    func uploadPickerFile(_ pickerModel: PickerFileModel) -> Observable<FileUploadModel> {
        let url = Constants.apiEndPoint.absoluteString + "/api/v1/Image/UploadNoToken"
        pickerModel.isUploading.accept(true)
        return pickerModel.mediaFromLibrary()
            .flatMap { self.uploadAsset($0, parameters: [:], uploadURL: url, progress: { pickerModel.uploadProgress.accept($0) }) }
    }
    
    func uploadPhoto(_ fixedPhoto: UIImage) -> Observable<FileUploadModel> {
        let uploadSubject = PublishSubject<FileUploadModel>()
        
        self.uploadImageFile(fixedPhoto, parameters: [:], uploadURL: "https://test-api.serey.io/api/v1/Image/UploadNoToken")
            .subscribe(onNext: { (uploaded, imageModel) in
                if uploaded {
                    uploadSubject.onNext(imageModel)
                } else {
                    uploadSubject.onError(FileUploadError.fileUploadError("Failed to upload photo."))
                }
            }, onError: { error in
                uploadSubject.onError(FileUploadError.error(error))
            }).disposed(by: self.disposeBag)
        
        return uploadSubject
    }
    
    fileprivate func createHeaders() -> HTTPHeaders {
        guard let userToken = AuthData.shared.userToken else { return [:] }
        
        let headers: HTTPHeaders = HTTPHeaders([
                   "Authorization": "Bearer \(userToken)",
                   "Content-Type": "application/json"
               ])
        
        return headers
    }
}

// MARK: - Networks
extension FileUploadService {
    
    fileprivate func uploadImageFile(_ fixedPhoto: UIImage, parameters: [String: Any], uploadURL: String) -> Observable<(Bool, FileUploadModel)> {
        let uploadSubject = PublishSubject<(Bool, FileUploadModel)>()
        
        Alamofire.Session.default.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                let valueData = (value as AnyObject).data(using: String.Encoding.utf8.rawValue)
                multipartFormData.append(valueData!, withName: key)
            }
            
            let imageData = fixedPhoto.jpegData(compressionQuality: 0.8)!
            let withName = "upfile"
            let filename = "\(Date().timeIntervalSince1970).jpg"
            let mimetype = "image/jpeg"
            multipartFormData.append(imageData, withName: withName, fileName: filename, mimeType: mimetype)
        }, to: uploadURL, headers: self.createHeaders())
            .responseDecodable { (response: DataResponse<FileUploadModel, AFError>) in
                switch response.result {
                case .success(let imageModel):
                    uploadSubject.onNext((true, imageModel))
                case .failure(let error):
                    if (response.response?.statusCode == 413) { // Entity Too Large
                        uploadSubject.onNext((false, FileUploadModel()))
                    } else {
                        uploadSubject.onError(error)
                    }
                }
        }
        
//        Alamofire.Session.default.upload(multipartFormData: { multipartFormData in
//            for (key, value) in parameters {
//                let valueData = (value as AnyObject).data(using: String.Encoding.utf8.rawValue)
//                multipartFormData.append(valueData!, withName: key)
//            }
//            multipartFormData.append(fixedPhoto.jpegData(compressionQuality: 0.8)!, withName: "upfile", fileName: "\(Date().timeIntervalSince1970).jpg", mimeType: "image/jpeg")
//        }, to: uploadURL, headers: self.createHeaders(), encodingCompletion: { result in
//
//            switch result {
//            case .success(let request, _, _):
//                #if DEBUG
//                request.responseString(completionHandler: { (uploadResponse: DataResponse<String>) in
//                    print(uploadResponse.result)
//                })
//                #endif
//                request.responseObject(completionHandler: { (uploadResponse: DataResponse<FileUploadModel>) in
//                    switch uploadResponse.result {
//                    case .success(let imageModel):
//                        uploadSubject.onNext((true, imageModel))
//                        break
//                    case .failure(let error) :
//                        if (uploadResponse.response?.statusCode == 413) { // Entity Too Large
//                            uploadSubject.onNext((false, FileUploadModel()))
//                        } else {
//                            uploadSubject.onError(error)
//                        }
//                        break
//                    }
//                })
//            case .failure(let error):
//                uploadSubject.onError(error)
//            }
//
//        })
        
        return uploadSubject
    }
    
//    fileprivate func uploadFile(_ url: URL, parameters: [String: Any], uploadURL: String) -> Observable<(Bool, FileUploadModel)> {
//        let uploadSubject = PublishSubject<(Bool, FileUploadModel)>()
//
//        DefaultAlamofireManager.sharedManager(30, false).upload(multipartFormData: { multipartFormData in
//            multipartFormData.append(url, withName: "upfile", fileName: url.lastPathComponent, mimeType: url.mimeType)
//        }, to: uploadURL, headers: self.createHeaders()) { result in
//            switch result {
//            case .success(let request, _, _):
//                #if DEBUG
//                request.responseString(completionHandler: { (uploadResponse: DataResponse<String>) in
//                    print(uploadResponse.result)
//                })
//                #endif
//                request.responseObject(completionHandler: { (uploadResponse: DataResponse<FileUploadModel>) in
//                    switch uploadResponse.result {
//                    case .success(let imageModel):
//                        uploadSubject.onNext((true, imageModel))
//                        break
//                    case .failure(let error) :
//                        if (uploadResponse.response?.statusCode == 413) { // Entity Too Large
//                            uploadSubject.onNext((false, FileUploadModel()))
//                        } else {
//                            uploadSubject.onError(error)
//                        }
//                        break
//                    }
//                })
//            case .failure(let error):
//                uploadSubject.onError(error)
//            }
//        }
//
//        return uploadSubject
//    }
}

// MARK: - Networks
extension FileUploadService {
    
    func uploadAsset<R: Decodable>(_ asset: AssetUploadModel, parameters: [String: Any], uploadURL: String, progress: @escaping (Double) -> Void = { _ in }) -> Observable<R> {
        let uploadSubject: PublishSubject<R> = .init()
        
        Alamofire.Session.default.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                let valueData = (value as AnyObject).data(using: String.Encoding.utf8.rawValue)
                multipartFormData.append(valueData!, withName: key)
            }
            
            if let image = asset.image {
                let imageData = image.imageData ?? image.jpegData(compressionQuality: 1)!
                multipartFormData.append(imageData, withName: "upfile", fileName: asset.filenameUrlEncoded, mimeType: asset.mimeType)
            } else if let url = asset.url {
                multipartFormData.append(url, withName: "upfile", fileName: asset.filenameUrlEncoded, mimeType: asset.mimeType)
            }
            #if DEBUG
            print(multipartFormData)
            #endif
        }, to: uploadURL, headers: self.createHeaders())
        .uploadProgress(closure: { uploadProgress in
            progress(uploadProgress.fractionCompleted)
            #if DEBUG
            print("Uploading: \(uploadProgress.fractionCompleted)")
            #endif
        })
        .responseDecodable { (response: DataResponse<R, AFError>) in
            switch response.result {
            case .success(let data):
                uploadSubject.onNext(data)
            case .failure(let error):
                uploadSubject.onError(FileUploadError.error(error))
            }
        }
        
        return uploadSubject
    }
}
