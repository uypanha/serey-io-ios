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
    
    func search(_ query: String) -> Observable<[PeopleModel]> {
        return self.provider.rx.requestObject(.searchAuthor(query: query), type: [PeopleModel].self)
            .asObservable()
    }
}
