//
//  ReplyCommentTableViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/14/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class ReplyCommentTableViewModel: BasePostDetailViewModel, ShouldReactToAction, ShouldPresent{
    
    enum Action {
        case upVotePressed(VotePostType, PostModel, BehaviorSubject<VotedType?>)
        case flagPressed(VotePostType, PostModel, BehaviorSubject<VotedType?>)
        case downVotePressed(DownvoteDialogViewModel.DownVoteType, PostModel, BehaviorSubject<VotedType?>)
        case refresh
    }
    
    enum ViewToPresent {
        case voteDialogController(VoteDialogViewModel)
        case downVoteDialogController(DownvoteDialogViewModel)
        case signInViewController
        case loading(Bool)
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let onCommentReplied: PublishSubject<Void>
    
    let title: BehaviorRelay<String>
    let commentHidden: BehaviorSubject<Bool>
    let commentViewModel: CommentTextViewModel
    
    init(_ comment: PostModel, title: String) {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        self.onCommentReplied = .init()
        
        self.title = .init(value: title)
        self.commentHidden = .init(value: false)
        
        self.commentViewModel = .init()
        super.init(comment.permlink, comment.author)
        
        self.post.accept(comment)
    }
    
    override func setUpRxObservers() {
        super.setUpRxObservers()
        
        setUpActionObservers()
        setUpCommentTextViewObservers()
    }
    
    override func clearCommentInput() {
        super.clearCommentInput()
        
        self.commentViewModel.clearInput()
    }
    
    override func onCommented(_ comment: PostModel) {
        self.update(reply: comment)
        self.onCommentReplied.onNext(())
    }
    
    override func prepareCells(_ replies: [PostModel]) -> [SectionItem] {
        var cells: [CellViewModel] = []
        cells.append(CommentCellViewModel(self.post.value, canReply: false).then { self.setUpCommentCellObservers($0) })
        cells.append(contentsOf: replies.map { CommentCellViewModel($0, canReply: false, leading: 42).then { self.setUpCommentCellObservers($0) } })
        if self.isDownloading.value && replies.isEmpty {
            cells.append(contentsOf: (0...3).map { _ in CommentCellViewModel(true) })
        }
        return [SectionItem(items: cells)]
    }
    
    override func postTitle() -> String {
        return self.title.value
    }
    
    override func notifyDataChanged(_ data: PostModel?) {
        super.notifyDataChanged(data)
        
        self.replies.accept(data?.replies ?? [])
        self.commentHidden.onNext(!AuthData.shared.isUserLoggedIn)
    }
    
    override func setUpCommentCellObservers(_ cellModel: CommentCellViewModel) {
        cellModel.shouldUpVote
            .map { Action.upVotePressed(.comment, $0, cellModel.isVoting) }
            ~> self.didActionSubject
            ~ cellModel.disposeBag
        
        cellModel.shouldFlag
            .map { Action.flagPressed(.comment, $0, cellModel.isVoting) }
            ~> self.didActionSubject
            ~ cellModel.disposeBag
        
        cellModel.shouldDownvote.asObservable()
            .map { Action.downVotePressed($0.0 == .flag ? .flagComment : .upVoteComment, $0.1, cellModel.isVoting) }
            ~> self.didActionSubject
            ~ cellModel.disposeBag
    }
    
    override func updateData(_ data: PostDetailResponse<PostModel>) {
        var post = data.content
        post.replies = data.replies
        self.post.accept(post)
        NotificationDispatcher.sharedInstance.dispatch(.postUpdated(permlink: data.content.permlink, author: data.content.author, post: post))
    }
    
    override func notificationReceived(_ notification: Notification) {
        super.notificationReceived(notification)
        guard let appNotif = notification.appNotification else { return }
        switch appNotif {
        case .userDidLogin, .userDidLogOut:
            self.commentHidden.onNext(!AuthData.shared.isUserLoggedIn)
        default:
            break
        }
    }
}

// MARK: - Preparations
extension ReplyCommentTableViewModel {
    
    fileprivate func updateReplies(_ replies: [PostModel]) {
        self.replies.append(contentsOf: replies)
    }
    
    fileprivate func update(reply: PostModel) {
        var replies = self.replies.value
        replies.insert(reply, at: 0)
        self.replies.accept(replies)
    }
}

// MARK: - Action Handlers
fileprivate extension ReplyCommentTableViewModel {
    
    func handleUpVotePressed(_ voteType: VotePostType, _ postModel: PostModel, _ isVoting: BehaviorSubject<VotedType?>) {
        if AuthData.shared.isUserLoggedIn {
            let voteDialogViewModel = VoteDialogViewModel(type: voteType == .comment ? .upVoteComment : .upvotePost)
            voteDialogViewModel.shouldConfirm
                .subscribe(onNext: { [weak self] weight in
                    self?.upVote(postModel, weight, isVoting)
                }) ~ voteDialogViewModel.disposeBag
            self.shouldPresent(.voteDialogController(voteDialogViewModel))
        } else {
            self.shouldPresent(.signInViewController)
        }
    }
    
    func handleFlagPressed(_ voteType: VotePostType, _ postModel: PostModel, _ isVoting: BehaviorSubject<VotedType?>) {
        if AuthData.shared.isUserLoggedIn {
            let voteDialogViewModel = VoteDialogViewModel(type: voteType == .comment ? .flagComment : .flagPost)
            voteDialogViewModel.shouldConfirm
                .subscribe(onNext: { [weak self] weight in
                    self?.flag(postModel, -weight, isVoting)
                }) ~ voteDialogViewModel.disposeBag
            self.shouldPresent(.voteDialogController(voteDialogViewModel))
        } else {
            self.shouldPresent(.signInViewController)
        }
    }
    
    func handlDownvotePressed(_ downvoteType: DownvoteDialogViewModel.DownVoteType, _ postModel: PostModel, _ isVoting: BehaviorSubject<VotedType?>) {
        if AuthData.shared.isUserLoggedIn {
            let downvoteViewModel = DownvoteDialogViewModel(downvoteType)
            downvoteViewModel.shouldConfirm
                .subscribe(onNext: { [weak self] _ in
                    let votedType : VotedType = (downvoteType == .upVoteComment || downvoteType == .upvotePost) ? .upvote : .flag
                    self?.downVote(postModel, votedType, isVoting)
                }) ~ downvoteViewModel.disposeBag
            self.shouldPresent(.downVoteDialogController(downvoteViewModel))
        } else {
            self.shouldPresent(.signInViewController)
        }
    }
}

// MARK: - SetUp RxObservers
extension ReplyCommentTableViewModel {
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .refresh:
                    self?.downloadData()
                    self?.replies.renotify()
                case .upVotePressed(let voteType, let postModel, let isVoting):
                    self?.handleUpVotePressed(voteType, postModel, isVoting)
                case .flagPressed(let voteType, let postModel, let isVoting):
                    self?.handleFlagPressed(voteType, postModel, isVoting)
                case .downVotePressed(let voteType, let postModel, let isVoting):
                    self?.handlDownvotePressed(voteType, postModel, isVoting)
                }
            }) ~ self.disposeBag
    }
    
    func setUpCommentTextViewObservers() {
        self.commentViewModel.shouldSendComment.asObservable()
            .subscribe(onNext: { [unowned self] comment in
                self.submitComment(comment, self.commentViewModel.isUploading)
            }) ~ self.disposeBag
    }
}
