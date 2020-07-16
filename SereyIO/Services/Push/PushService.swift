//
//  PushService.swift
//  SereyIO
//
//  Created by Panha Uy on 4/23/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import AnyCodable
import Moya

class PushService: AppService<PushApi> {
    
    private func provider(_ accessToken: String? = nil) -> MoyaProvider<PushApi> {
        var plugins: [PluginType] = []
        if let token = accessToken {
            let tokenAuth = token
            plugins.append(AccessTokenPlugin { _ in tokenAuth })
        }
        #if DEBUG
        plugins.append(NetworkLoggerPlugin())
        #endif
        let manager = DefaultAlamofireManager.sharedManager(self.timeOut)
        return MoyaProvider<PushApi>(session: manager, plugins: plugins)
    }
    
    func register(_ username: String, _ token: String) -> Observable<NotificationResponse> {
        return self.provider.rx.requestObject(.login, type: NotificationResponse.self)
            .asObservable()
            .filter { $0.data != nil }
            .flatMap { response -> Observable<NotificationResponse> in
                return self.provider(response.data?.token ?? "")
                    .rx.requestObject(.register(username: username, token: token), type: NotificationResponse.self)
                    .asObservable()
            }.asObservable()
    }
    
    func remove(_ username: String) -> Observable<NotificationResponse> {
        return self.provider.rx.requestObject(.login, type: NotificationResponse.self)
            .asObservable()
            .filter { $0.data != nil }
            .flatMap { response -> Observable<NotificationResponse> in
                return self.provider(response.data?.token ?? "")
                    .rx.requestObject(.remove(username: username), type: NotificationResponse.self)
                    .asObservable()
            }.asObservable()
    }
    
    func update(_ username: String, _ token: String) -> Observable<NotificationResponse> {
        return self.provider.rx.requestObject(.login, type: NotificationResponse.self)
        .asObservable()
        .filter { $0.data != nil }
        .flatMap { response -> Observable<NotificationResponse> in
            return self.provider(response.data?.token ?? "")
                .rx.requestObject(.updateToken(username: username, token: token), type: NotificationResponse.self)
                .asObservable()
        }.asObservable()
    }
}

// MAKR: - Notification Model
struct NotificationResponse: Codable {
    
    let status: NotificationStatusModel
    let data: NotificationDataModel?
    
    enum CodingKeys: String, CodingKey {
        case status
        case data
    }
}

// MARK: Notification Status
struct NotificationStatusModel: Codable {
    
    let code: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case code = "responseCode"
        case message = "responseMessage"
    }
}

// MARK: Notification Data
struct NotificationDataModel: Codable {
    
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case token
    }
}
