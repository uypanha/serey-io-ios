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
    
    func getDiscussionList(_ type: DiscussionType, _ query: QueryDiscussionsBy) -> Observable<[PostModel]> {
        return self.provider.rx.requestObject(.getDiscussions(type, query), type: [PostModel].self)
            .asObservable()
    }
    
    func getPostDetail(permlink: String, authorName: String) -> Observable<PostDetailResponse> {
        return self.provider.rx.requestObject(.getPostDetail(permlink: permlink, authorName: authorName), type: PostDetailResponse.self)
            .asObservable()
    }
    
    func submitPost(_ submitModel: SubmitPostModel) -> Observable<BlockChainResponse> {
        return self.provider.rx.requestObject(.submitPost(submitModel), type: DataResponseModel<BlockChainResponse>.self)
            .asObservable()
            .map { $0.data }
    }
}
