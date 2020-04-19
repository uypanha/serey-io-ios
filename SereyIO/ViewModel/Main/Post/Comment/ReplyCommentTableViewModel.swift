//
//  ReplyCommentTableViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/14/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class ReplyCommentTableViewModel: BaseCellViewModel, CollectionMultiSectionsProviderModel, DownloadStateNetworkProtocol, ShouldReactToAction {
    
    enum Action {
        case refresh
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<ReplyCommentTableViewModel.Action>()
    
    let cells: BehaviorRelay<[SectionItem]>
    let title: BehaviorRelay<String>
    let comment: BehaviorRelay<PostModel>
    let replies: BehaviorRelay<[PostModel]>
    let endRefresh: BehaviorSubject<Bool>
    
    let commentViewModel: CommentTextViewModel
    
    let isDownloading: BehaviorRelay<Bool>
    let discussionService: DiscussionService
    
    init(_ comment: PostModel, title: String) {
        self.title = BehaviorRelay(value: title)
        
        self.isDownloading = BehaviorRelay(value: false)
        self.cells = BehaviorRelay(value: [])
        self.comment = BehaviorRelay(value: comment)
        self.replies = BehaviorRelay(value: comment.replies ?? [])
        self.endRefresh = BehaviorSubject(value: true)
        
        self.discussionService = DiscussionService()
        
        self.commentViewModel = CommentTextViewModel()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension ReplyCommentTableViewModel {
    
    func downloadData() {
    }
    
    private func submitComment(_ comment: String) {
        let submitCommentModel = self.prepareSubmitCommentModel(comment)
        self.commentViewModel.isUploading.onNext(true)
        self.discussionService.submitComment(submitCommentModel)
            .subscribe(onNext: { [weak self] data in
                self?.updateReplies(data.data)
                self?.commentViewModel.clearInput()
                self?.commentViewModel.isUploading.onNext(false)
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                self?.commentViewModel.isUploading.onNext(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations
extension ReplyCommentTableViewModel {
    
    fileprivate func updateReplies(_ replies: [PostModel]) {
        self.replies.append(contentsOf: replies)
    }
    
    fileprivate func prepareCells(_ replies: [PostModel]) -> [SectionItem] {
        var cells: [CellViewModel] = []
        cells.append(CommentCellViewModel(self.comment.value, canReply: false))
        cells.append(contentsOf: replies.map { CommentCellViewModel($0, canReply: false, leading: 42).then { self.setUpCommentCellObservers($0) } })
        if self.isDownloading.value && replies.isEmpty {
            cells.append(contentsOf: (0...3).map { _ in CommentCellViewModel(true) })
        }
        return [SectionItem(items: cells)]
    }
    
    fileprivate func prepareSubmitCommentModel(_ comment: String) -> SubmitCommentModel {
        let permlink = self.comment.value.permlink
        let author = self.comment.value.authorName
        let title = self.title.value
        let category = self.comment.value.categoryItem.first ?? ""
        
        return SubmitCommentModel(parentAuthor: author, parentPermlink: permlink, title: title, body: comment, mainCategory: category)
    }
}

// MARK: - SetUp RxObservers
extension ReplyCommentTableViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
        setUpCommentTextViewObservers()
    }
    
    func setUpContentChangedObservers() {
        self.comment.asObservable()
            .map { _ in self.replies.value }
            .map { self.prepareCells($0) }
            ~> self.cells
            ~ self.disposeBag
        
        self.replies.asObservable()
            .map { self.prepareCells($0) }
            ~> self.cells
            ~ self.disposeBag
        
//        self.isDownloading.asObservable()
//            .filter { !$0 }
//            .map { !$0 }
//            ~> self.endRefresh
//            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .refresh:
                    self?.endRefresh.onNext(true)
                }
            }) ~ self.disposeBag
    }
    
    func setUpCommentTextViewObservers() {
        self.commentViewModel.shouldSendComment.asObservable()
            .subscribe(onNext: { [weak self] comment in
                self?.submitComment(comment)
            }) ~ self.disposeBag
    }
    
    func setUpCommentCellObservers(_ cellModel: CommentCellViewModel) {
    }
}
