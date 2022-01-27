//
//  PostDetailViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/6/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxRelay
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
        case dismiss
        case moreDialogController(BottomListMenuViewModel)
        case editPostController(CreatePostViewModel)
        case deletePostDialog(confirm: () -> Void)
        case replyComment(ReplyCommentTableViewModel)
        case voteDialogController(VoteDialogViewModel)
        case downVoteDialogController(DownvoteDialogViewModel)
        case signInViewController
        case loading(Bool)
        case userAccountController(UserAccountViewModel)
        case votersViewController(VoterListViewModel)
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
        self.init(post.permlink, post.author)
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
        
        let postDetailViewModel = data == nil ? PostDetailCellViewModel(true) : PostDetailCellViewModel(data).then {
            self.setUpPostDetailViewModelObsevers($0)
        }
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
    
    private func deletePost(_ post: PostModel) {
        self.shouldPresent(.loading(true))
        self.discussionService.deletePost(post.author, post.permlink)
            .subscribe(onNext: { [weak self] _ in
                NotificationDispatcher.sharedInstance.dispatch(.postDeleted(permlink: post.permlink, author: post.author))
                self?.shouldPresent(.loading(false))
                self?.shouldPresent(.dismiss)
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Action Handlers
fileprivate extension PostDetailViewModel {
    
    func handleMorePressed() {
        let items: [PostMenu] = self.post.value?.prepareOptionMenu() ?? []
        let bottomMenuViewModel = BottomListMenuViewModel(header: " ", items.map { $0.cellModel })
        
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
                if let post = self.post.value {
                    self.deletePost(post)
                }
            }))
        case.reportPost:
            break
        case .hidePost:
            break
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
    
    func handleProfilePressed(of postModel: PostModel) {
        let userAccountViewModel = UserAccountViewModel(postModel.author)
        self.shouldPresent(.userAccountController(userAccountViewModel))
    }
    
    func handleShowVotersPressed() {
        if let voters = self.post.value?.voters {
            let voterListViewModel = VoterListViewModel(voters)
            
            voterListViewModel.shouldShowUserAccount.asObservable()
                .subscribe(onNext: { [weak self] userAccountViewModel in
                    self?.shouldPresent(.userAccountController(userAccountViewModel))
                }) ~ voterListViewModel.disposeBag
            
            self.shouldPresent(.votersViewController(voterListViewModel))
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
    
    func setUpPostDetailViewModelObsevers(_ viewModel: PostDetailCellViewModel) {
        viewModel.shouldShowAuthorProfile.asObservable()
            .subscribe(onNext: { [weak self] postModel in
                self?.handleProfilePressed(of: postModel)
            }) ~ viewModel.disposeBag
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
        
        viewModel.shouldShowVoters.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.handleShowVotersPressed()
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
    case reportPost
    case hidePost
    
    var cellModel: PostMenuCellViewModel {
        return PostMenuCellViewModel(self)
    }
    
    var imageTextModel: ImageTextModel {
        switch self {
        case .edit:
            return ImageTextModel(image: R.image.editIcon(), titleText: R.string.common.edit.localized())
        case .delete:
            return ImageTextModel(image: R.image.trashIcon(), titleText: R.string.common.delete.localized())
        case .hidePost:
            return ImageTextModel(image: R.image.hidePostIcon(), titleText: "Hide post")
        case .reportPost:
            return ImageTextModel(image: R.image.reportPostIcon(), titleText: "Report post")
        }
    }
}
