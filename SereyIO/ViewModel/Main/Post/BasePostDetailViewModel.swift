//
//  BasePostDetailViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/22/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class BasePostDetailViewModel: BaseCellViewModel, CollectionMultiSectionsProviderModel, DownloadStateNetworkProtocol {
    
    let cells: BehaviorRelay<[SectionItem]>
    
    let permlink: BehaviorRelay<String>
    let authorName: BehaviorRelay<String>
    let post: BehaviorRelay<PostModel?>
    let replies: BehaviorRelay<[PostModel]>
    
    let isMoreHidden: BehaviorSubject<Bool>
    let endRefresh: BehaviorSubject<Bool>
    
    let discussionService: DiscussionService
    let isDownloading: BehaviorRelay<Bool>
    
    init(_ permlink: String, _ authorName: String) {
        self.permlink = BehaviorRelay(value: permlink)
        self.authorName = BehaviorRelay(value: authorName)
        self.post = BehaviorRelay(value: nil)
        self.replies = BehaviorRelay(value: [])
        
        self.isMoreHidden = BehaviorSubject(value: true)
        self.endRefresh = BehaviorSubject(value: true)
        
        self.cells = BehaviorRelay(value: [])
        self.discussionService = DiscussionService()
        self.isDownloading = BehaviorRelay(value: false)
        super.init()
        
        setUpRxObservers()
    }
    
    convenience init(_ post: PostModel) {
        self.init(post.permlink, post.authorName)
        self.post.accept(post)
    }
    
    internal func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func downloadData() {
        if !self.isDownloading.value {
            self.isDownloading.accept(true)
            self.fetchPostDetial()
        }
    }
    
    internal func fetchPostDetial() {
        self.replies.renotify()
        self.discussionService.getPostDetail(permlink: self.permlink.value, authorName: self.authorName.value)
            .subscribe(onNext: { [weak self] response in
                self?.isDownloading.accept(false)
                self?.updateData(response)
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    internal func notifyDataChanged(_ data: PostModel?) {
        let isMorePresent = AuthData.shared.isUserLoggedIn ? data?.authorName == AuthData.shared.username : false
        let isOVerAWeek = data?.isOverAWeek ?? false
        self.isMoreHidden.onNext(isOVerAWeek || !isMorePresent)
    }
    
    internal func setUpCommentCellObservers(_ cellModel: CommentCellViewModel) {
    }
    
    internal func clearCommentInput() {
    }
    
    internal func prepareCells(_ replies: [PostModel]) -> [SectionItem] {
        var cells: [CellViewModel] = []
        cells.append(contentsOf: replies.map { CommentCellViewModel($0).then { self.setUpCommentCellObservers($0) } })
        if self.isDownloading.value && replies.isEmpty {
            cells.append(contentsOf: (0...3).map { _ in CommentCellViewModel(true) })
        }
        return [SectionItem(items: cells)]
    }
    
    internal func updateData(_ data: PostDetailResponse) {
        self.post.accept(data.content)
        self.replies.accept(data.replies)
    }
}

// MARK: - Networks
extension BasePostDetailViewModel {
    
    internal func submitComment(_ comment: String, _ isUploading: BehaviorSubject<Bool>) {
        let submitCommentModel = self.prepareSubmitCommentModel(comment)
        isUploading.onNext(true)
        self.discussionService.submitComment(submitCommentModel)
            .subscribe(onNext: { [weak self] _ in
                isUploading.onNext(false)
                self?.fetchPostDetial()
                self?.clearCommentInput()
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                isUploading.onNext(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    internal func upVote(_ post: PostModel, _ weight: Int, _ isVoting: BehaviorSubject<VotedType?>) {
        isVoting.onNext(.upvote)
        self.discussionService.upVote(post.permlink, author: post.authorName, weight: weight)
            .subscribe(onNext: { [weak self] _ in
                self?.fetchPostDetial()
                isVoting.onNext(nil)
            }, onError: { [weak self] error in
                isVoting.onNext(nil)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    internal func flag(_ post: PostModel, _ weight: Int, _ isVoting: BehaviorSubject<VotedType?>) {
        isVoting.onNext(.flag)
        self.discussionService.flag(post.permlink, author: post.authorName, weight: weight)
            .subscribe(onNext: { [weak self] _ in
                self?.fetchPostDetial()
                isVoting.onNext(nil)
            }, onError: { [weak self] error in
                isVoting.onNext(nil)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    internal func downVote(_ post: PostModel, _ votedType: VotedType, _ isVoting: BehaviorSubject<VotedType?>) {
        isVoting.onNext(votedType)
        self.discussionService.downVote(post.permlink, author: post.authorName)
            .subscribe(onNext: { [weak self] _ in
                self?.fetchPostDetial()
                isVoting.onNext(nil)
            }, onError: { [weak self] error in
                isVoting.onNext(nil)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension BasePostDetailViewModel {
    
    enum VotePostType {
        case comment
        case article
    }
    
    internal func prepareSubmitCommentModel(_ comment: String) -> SubmitCommentModel {
        let permlink = self.post.value?.permlink ?? ""
        let author = self.post.value?.authorName ?? ""
        let title = self.post.value?.title ?? ""
        let category = self.post.value?.categoryItem.first ?? ""
        
        return SubmitCommentModel(parentAuthor: author, parentPermlink: permlink, title: title, body: comment, mainCategory: category)
    }
}

// MARK: - SetUp RxObservers
private extension BasePostDetailViewModel {
    
    func setUpContentChangedObservers() {
        self.post.asObservable()
            .subscribe(onNext: { [weak self] discussion in
                self?.notifyDataChanged(discussion)
            }) ~ self.disposeBag
        
        self.replies.asObservable()
            .map { self.prepareCells($0) }
            ~> self.cells
            ~ self.disposeBag
        
        self.isDownloading.asObservable()
            .filter { !$0 }
            .map { !$0 }
            ~> self.endRefresh
            ~ self.disposeBag
    }
}
