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

class PushService: AppService<PushApi> {
    
    func register(_ username: String, _ token: String) -> Observable<AnyCodable> {
        return self.provider.rx.requestObject(.register(username: username, token: token), type: AnyCodable.self)
            .asObservable()
    }
    
    func remove(_ username: String) -> Observable<AnyCodable> {
        return self.provider.rx.requestObject(.remove(username: username), type: AnyCodable.self)
            .asObservable()
    }
}
