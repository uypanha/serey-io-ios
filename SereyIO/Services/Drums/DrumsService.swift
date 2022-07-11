//
//  DrumsService.swift
//  SereyIO
//
//  Created by Panha Uy on 30/6/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class DrumsService: AppService<DrumsApi> {
    
    func fetchAllDrums(_ pagination: PaginationRequestModel) -> Observable<[PostModel]> {
        return self.provider.rx.requestObject(.allDrums(pagination), type: [PostModel].self)
            .asObservable()
    }
}
