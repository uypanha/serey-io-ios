//
//  PostDetailViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class PostDetailViewModel: BasePostDetailViewModel, ShouldReactToAction, ShouldPresent{
    
    enum Action {
        case morePressed
        case upVotePressed(VotePostType, PostModel, BehaviorSubject<VotedType?>)
        case flagPressed(VotePostType, PostModel, BehaviorSubject<VotedType?>)
        case downVotePressed(DownvoteDialogViewModel.DownVoteType, PostModel, BehaviorSubject<VotedType?>)
        case refresh
        case replyCommentPressed(CommentCellViewModel)
    }
    
    enum ViewToPresent {
        case moreDialogController(BottomListMenuViewModel)
        case editPostController(CreatePostViewModel)
        case deletePostDialog(confirm: () -> Void)
        case replyComment(ReplyCommentTableViewModel)
        case voteDialogController(VoteDialogViewModel)
        case downVoteDialogController(DownvoteDialogViewModel)
        case signInViewController
        case loading(Bool)
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let postViewModel: BehaviorRelay<PostDetailCellViewModel?>
    let commentPostViewModel: BehaviorRelay<PostCommentViewModel?>
    let sereyValueText: BehaviorSubject<String>
    
    override init(_ permlink: String, _ authorName: String) {
        self.postViewModel = BehaviorRelay(value: nil)
        self.commentPostViewModel = BehaviorRelay(value: nil)
        self.sereyValueText = BehaviorSubject(value: "")
        super.init(permlink, authorName)
    }
    
    convenience init(_ post: PostModel) {
        self.init(post.permlink, post.authorName)
        self.post.accept(post)
    }
    
    override func setUpRxObservers() {
        super.setUpRxObservers()
        
        setUpActionObservers()
    }
    
    override func clearCommentInput() {
        super.clearCommentInput()
        
        self.commentPostViewModel.value?.clearInput()
    }
    
    override func notifyDataChanged(_ data: PostModel?) {
        super.notifyDataChanged(data)
        
        let postDetailViewModel = data == nil ? PostDetailCellViewModel(true) : PostDetailCellViewModel(data)
        let commentPostViewModel = data == nil ? PostCommentViewModel(true) : PostCommentViewModel(data).then {
            self.setUpCommentViewModelObservers($0)
        }
        self.postViewModel.accept(postDetailViewModel)
        self.commentPostViewModel.accept(commentPostViewModel)
        self.sereyValueText.onNext(data?.sereyValue ?? "")
    }
    
    override func setUpCommentCellObservers(_ cellModel: CommentCellViewModel) {
        cellModel.shouldReplyComment
            .map { Action.replyCommentPressed($0) }
            ~> self.didActionSubject
            ~ cellModel.disposeBag
        
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
}

// MARK: - Networks
extension PostDetailViewModel {
    
    private func deletePost() {
        if let post = self.post.value {
            self.shouldPresent(.loading(true))
            self.discussionService.deletePost(post.authorName, post.permlink)
                .subscribe(onNext: { [weak self] _ in
                    self?.shouldPresent(.loading(false))
                }, onError: { [weak self] error in
                    self?.shouldPresent(.loading(false))
                    let errorInfo = ErrorHelper.prepareError(error: error)
                    self?.shouldPresentError(errorInfo)
                }) ~ self.disposeBag
        }
    }
}

// MARK: - Action Handlers
fileprivate extension PostDetailViewModel {
    
    func handleMorePressed() {
        let items: [PostMenu] = [.edit, .delete]
        let bottomMenuViewModel = BottomListMenuViewModel(items.map { $0.cellModel })
        
        bottomMenuViewModel.shouldSelectMenuItem.asObservable()
            .subscribe(onNext: { [weak self] item in
                if let itemType = (item as? PostMenuCellViewModel)?.type {
                    self?.handleMenuPressed(itemType)
                }
            }) ~ bottomMenuViewModel.disposeBag
        
        self.shouldPresent(.moreDialogController(bottomMenuViewModel))
    }
    
    func handleMenuPressed(_ type: PostMenu) {
        switch type {
        case .edit:
            if let post = self.post.value {
                let createPostViewModel = CreatePostViewModel(.edit(post))
                self.shouldPresent(.editPostController(createPostViewModel))
            }
        case .delete:
            self.shouldPresent(.deletePostDialog(confirm: {
                self.deletePost()
            }))
        }
    }
    
    func handleReplyCommentPressed(_ cellViewModel: CommentCellViewModel) {
        if let commentData = cellViewModel.post.value {
            let replyCommentViewModel = ReplyCommentTableViewModel(commentData, title: self.post.value?.title ?? "")
            self.shouldPresent(.replyComment(replyCommentViewModel))
        }
    }
    
    func handleUpVotePressed(_ voteType: VotePostType, _ postModel: PostModel, _ isVoting: BehaviorSubject<VotedType?>) {
        if AuthData.shared.isUserLoggedIn {
            let voteDialogViewModel = VoteDialogViewModel(100, type: voteType == .comment ? .upVoteComment : .upvotePost)
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
            let voteDialogViewModel = VoteDialogViewModel(100, type: voteType == .comment ? .flagComment : .flagPost)
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
extension PostDetailViewModel {
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .morePressed:
                    self?.handleMorePressed()
                case .refresh:
                    self?.downloadData()
                    self?.replies.renotify()
                case .replyCommentPressed(let commentCell):
                    self?.handleReplyCommentPressed(commentCell)
                case .upVotePressed(let type, let post, let votedType):
                    self?.handleUpVotePressed(type, post, votedType)
                case .flagPressed(let type, let post, let votedType):
                    self?.handleFlagPressed(type, post, votedType)
                case .downVotePressed(let type, let post, let votedType):
                    self?.handlDownvotePressed(type, post, votedType)
                }
            }) ~ self.disposeBag
    }
    
    func setUpCommentViewModelObservers(_ viewModel: PostCommentViewModel) {
        viewModel.shouldUpVote.asObservable()
            .map { Action.upVotePressed(.article, $0, viewModel.isVoting) }
            ~> self.didActionSubject
            ~ viewModel.disposeBag
        
        viewModel.shouldFlag.asObservable()
            .map { Action.flagPressed(.article, $0, viewModel.isVoting) }
            ~> self.didActionSubject
            ~ viewModel.disposeBag
        
        viewModel.shouldDownvote.asObservable()
            .map { Action.downVotePressed($0.0 == .flag ? .flagPost : .upvotePost, $0.1, viewModel.isVoting) }
            ~> self.didActionSubject
            ~ viewModel.disposeBag
        
        viewModel.shouldComment.asObservable()
            .subscribe(onNext: { [weak self] comment in
                self?.submitComment(comment, viewModel.isUploading)
            }) ~ viewModel.disposeBag
    }
}

// MARK: - PostMenuCellViewModel
class PostMenuCellViewModel: ImageTextCellViewModel {
    
    let type: PostMenu
    
    init(_ type: PostMenu) {
        self.type = type
        super.init(model: type.imageTextModel)
    }
}

// MARK: - Post Menu
enum PostMenu {
    case edit
    case delete
    
    var cellModel: PostMenuCellViewModel {
        return PostMenuCellViewModel(self)
    }
    
    var imageTextModel: ImageTextModel {
        switch self {
        case .edit:
            return ImageTextModel(image: R.image.editIcon(), titleText: R.string.common.edit.localized())
        case .delete:
            return ImageTextModel(image: R.image.trashIcon(), titleText: R.string.common.delete.localized())
        }
    }
}
