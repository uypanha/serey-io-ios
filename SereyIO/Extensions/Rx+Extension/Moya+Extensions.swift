//
//  Moya+Extensions.swift
//  SereyIO
//
//  Created by Phanha Uy on 10/8/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

extension Reactive where Base: MoyaProviderType {
    
    /// Designated request-making method.
    ///
    /// - Parameters:
    ///   - token: Entity, which provides specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: Single response object.
    func requestObject<T: Decodable>(_ token: Base.Target, type: T.Type, callbackQueue: DispatchQueue? = nil) -> Single<T> {
        return Single.create { [weak base] single in
            let cancellableToken = base?.request(token, callbackQueue: callbackQueue, progress: nil) { result in
                switch result {
                case let .success(response):
                    let decoder = JSONDecoder()
                    let str = String(decoding: response.data, as: UTF8.self)
                    print("Data Response ==> \(str)")
                    
                    if response.statusCode >= 200 && response.statusCode <= 202 {
                        if let dataResponse = try? decoder.decode(T.self, from: response.data) {
                            single(.success(dataResponse))
                        } else {
                            single(.failure(NSError(domain: "Data Mapping Error", code: 0, userInfo: nil)))
                        }
                    } else {
                        if let errorModel = try? decoder.decode(AppApiError.self, from: response.data) {
                            single(.failure(AppError.appApiError(errorModel, code: response.statusCode)))
                        } else {
                            single(.failure(NSError(domain: "Unknown Error", code: response.statusCode, userInfo: nil)))
                        }
                    }
                case let .failure(error):
                    single(.failure(error))
                }
            }
            
            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
    
//    /// Designated request-making method with progress.
//    func requestWithProgress(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> Observable<ProgressResponse> {
//        let progressBlock: (AnyObserver) -> (ProgressResponse) -> Void = { observer in
//            return { progress in
//                observer.onNext(progress)
//            }
//        }
//
//        let response: Observable<ProgressResponse> = Observable.create { [weak base] observer in
//            let cancellableToken = base?.request(token, callbackQueue: callbackQueue, progress: progressBlock(observer)) { result in
//                switch result {
//                case .success:
//                    observer.onCompleted()
//                case let .failure(error):
//                    observer.onError(error)
//                }
//            }
//
//            return Disposables.create {
//                cancellableToken?.cancel()
//            }
//        }
//
//        // Accumulate all progress and combine them when the result comes
//        return response.scan(ProgressResponse()) { last, progress in
//            let progressObject = progress.progressObject ?? last.progressObject
//            let response = progress.response ?? last.response
//            return ProgressResponse(progress: progressObject, response: response)
//        }
//    }
}
