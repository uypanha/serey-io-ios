//
//  DiscussionService.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/26/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import AnyCodable

class DiscussionService: AppService<DiscussionApi> {
    
    func getCategories() -> Observable<[DiscussionCategoryModel]> {
        return self.provider.rx.requestObject(.getCategories, type: [DiscussionCategoryModel].self)
            .asObservable()
    }
    
    func getDiscussionList(_ type: DiscussionType, _ pageModel: PaginationRequestModel) -> Observable<[PostModel]> {
        return self.provider.rx.requestObject(.getDiscussions(type, pageModel), type: [PostModel].self)
            .asObservable()
    }
    
    func getPostDetail(permlink: String, authorName: String) -> Observable<PostDetailResponse> {
        return self.provider.rx.requestObject(.getPostDetail(permlink: permlink, authorName: authorName), type: PostDetailResponse.self)
            .asObservable()
    }
    
    func getCommentsReply(of username: String, type: GetCommentType) -> Observable<ListDataResponseModel<CommentReplyModel>> {
        return self.provider.rx.requestObject(.getCommentReply(username: username, type: type), type: ListDataResponseModel<CommentReplyModel>.self)
            .asObservable()
    }
    
    func submitPost(_ submitModel: SubmitPostModel) -> Observable<BlockChainResponse> {
        return self.provider.rx.requestObject(.submitPost(submitModel), type: DataResponseModel<BlockChainResponse>.self)
            .asObservable()
            .map { $0.data }
    }
    
    func submitComment(_ submitModel: SubmitCommentModel) -> Observable<DataResponseModel<[PostModel]>> {
        return self.provider.rx.requestObject(.submitComment(submitModel), type: DataResponseModel<[PostModel]>.self)
            .asObservable()
    }
    
    func deletePost(_ username: String, _ permlink: String) -> Observable<AnyCodable> {
        return self.provider.rx.requestObject(.deletPost(username: username, permlink: permlink), type: AnyCodable.self)
            .asObservable()
    }
    
    func upVote(_ permlink: String, author: String, weight: Int) -> Observable<BlockChainResponse> {
        return self.provider.rx.requestObject(.upVote(permlink: permlink, author: author, weight: weight), type: DataResponseModel<BlockChainResponse>.self)
            .asObservable()
            .map { $0.data }
    }
    
    func flag(_ permlink: String, author: String, weight: Int) -> Observable<BlockChainResponse> {
        return self.provider.rx.requestObject(.flag(permlink: permlink, author: author, weight: weight), type: DataResponseModel<BlockChainResponse>.self)
            .asObservable()
            .map { $0.data }
    }
    
    func downVote(_ permlink: String, author: String) -> Observable<BlockChainResponse> {
        return self.provider.rx.requestObject(.downVote(permlink: permlink, author: author), type: DataResponseModel<BlockChainResponse>.self)
            .asObservable()
            .map { $0.data }
    }
    
}
