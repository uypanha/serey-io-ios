//
//  NotificationService.swift
//  SereyIO
//
//  Created by Panha Uy on 9/27/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import AnyCodable

class NotificationService: AppService<NotificationApi> {
    
    func fetchNotifications(_ pageModel: PaginationRequestModel) -> Observable<NotificationsResponseModel> {
        return self.provider.rx.requestObject(.notifications(pageModel), type: NotificationsResponseModel.self)
            .asObservable()
    }
    
    func updateRead(_ id: String) -> Observable<NotificationModel> {
        return self.provider.rx.requestObject(.updateRead(id), type: NotificationModel.self)
            .asObservable()
    }
}
