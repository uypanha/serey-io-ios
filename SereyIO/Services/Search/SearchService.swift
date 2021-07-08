//
//  SearchService.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/4/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class SearchService: AppService<SearchApi> {
    
    func search(_ model: PaginationRequestModel) -> Observable<[PostModel]> {
        return self.provider.rx.requestObject(.search(model), type: [PostModel].self)
            .asObservable()
            .map { $0 }
    }
}
