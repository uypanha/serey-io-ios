//
//  DiscussionService.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/26/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class DiscussionService: AppService<DiscussionApi> {
    
    func getCategories() -> Observable<[DiscussionCategoryModel]> {
        return self.provider.rx.requestObject(.getCategories, type: [DiscussionCategoryModel].self)
            .asObservable()
    }
    
    func getDiscussionList(_ type: DiscussionType, _ query: QueryDiscussionsBy) -> Observable<[DiscussionModel]> {
        return self.provider.rx.requestObject(.getDiscussions(type, query), type: [DiscussionModel].self)
            .asObservable()
    }
}
