//
//  SearchService.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/4/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class SearchService: AppService<SearchApi> {
    
    func search(_ query: String) -> Observable<[PeopleModel]> {
        return self.provider.rx.requestObject(.searchAuthor(query: query), type: ListDataResponseModel<PeopleModel>.self)
            .asObservable()
            .map { $0.data }
    }
}
