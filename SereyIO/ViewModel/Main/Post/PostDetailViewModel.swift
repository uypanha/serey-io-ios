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
        case reportPostController(ReportPostViewModel)
        case confirmViewController(ConfirmDialogViewModel)
        case postsByCategoryController(PostTableViewModel)
        case shareLink(URL, String)
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
    
    func hidePost(_ post: PostModel) {
        self.shouldPresent(.loading(true))
        self.discussionService.hidePost(with: post.id)
            .subscribe(onNext: { [weak self] data in
                self?.shouldPresent(.loading(false))
                var post = post
                post.isHidden = true
                NotificationDispatcher.sharedInstance.dispatch(.postUpdated(permlink: post.permlink, author: post.author, post: post))
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
        if !AuthData.shared.isUserLoggedIn {
            self.shouldPresent(.signInViewController)
            return
        }
        let items: [PostMenu] = self.post.value?.prepareOptionMenu() ?? []
        let bottomMenuViewModel = BottomListMenuViewModel(header: self.post.value?.prepareOptionMenuTitle(), items.map { $0.cellModel })
        bottomMenuViewModel.headerFont = .customFont(with: 22, weight: .medium)
        
        bottomMenuViewModel.shouldSelectMenuItem.asObservable()
            .subscribe(onNext: { [weak self] item in
                if let itemType = (item as? PostMenuCellViewModel)?.type {
                    self?.handleMenuPressed(itemType)
                    return
                }
                
                if let itemType = (item as? PostOptionCellViewModel)?.postOption {
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
            if let post = self.post.value {
                self.shouldPresent(.reportPostController(.init(with: post)))
            }
        case .hidePost:
            if let post = self.post.value {
                let title = "Hide this post?"
                let message = "By clicking “Hide Post” you won’t see this post form “\(post.author)” in your feed. And it also a button for undo to cancel this action right after this post it submmited."
                let action = ActionModel("Hide Post", style: .default) {
                    self.hidePost(post)
                }
                let confirmDialogViewModel = ConfirmDialogViewModel(icon: R.image.infoYellowIcon(), title: title, message: message, action: action)
                self.shouldPresent(.confirmViewController(confirmDialogViewModel))
            }
        }
    }
    
    func handleReplyCommentPressed(_ cellViewModel: CommentCellViewModel) {
        if let commentData = cellViewModel.post.value {
            let replyCommentViewModel = ReplyCommentTableViewModel(commentData, title: self.post.value?.title ?? "")
            
            replyCommentViewModel.onCommentReplied.asObservable()
                .subscribe(onNext: { [weak self] _ in
                    self?.fetchPostDetial()
                }) ~ replyCommentViewModel.disposeBag
            
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
    
    func handleSharePressed() {
        if let post = self.post.value {
            let link = "https://serey.io/authors/\(post.author)/\(post.permlink)"
            if let url = URL(string: link) {
                self.shouldPresent(.shareLink(url, post.title))
            }
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
        
        viewModel.shouldShowPostsByCategory.asObservable()
            .subscribe(onNext: { [weak self] category in
                let postTableViewModel = PostTableViewModel(.byCategoryId(category), .init(value: nil))
                self?.shouldPresent(.postsByCategoryController(postTableViewModel))
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
        
        viewModel.shouldShare.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.handleSharePressed()
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
    
    var cellModel: CellViewModel {
        switch self {
        case .reportPost, .hidePost:
            return PostOptionCellViewModel(self)
        default:
            return PostMenuCellViewModel(self)
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .delete:
            return R.image.trashIcon()
        case .edit:
            return R.image.editIcon()
        case .hidePost:
            return R.image.hidePostIcon()
        case .reportPost:
            return R.image.reportPostIcon()
        }
    }
    
    var title: String {
        switch self {
        case .delete:
            return R.string.common.delete.localized()
        case .edit:
            return R.string.common.edit.localized()
        case .hidePost:
            return "Hide this post"
        case .reportPost:
            return "Report Post"
        }
    }
    
    var subTitle: String? {
        switch self {
        case .hidePost:
            return "I’m not feeling good seeing this post"
        case .reportPost:
            return "I’m concerned about this post"
        default:
            return nil
        }
    }
    
    var imageTextModel: ImageTextModel {
        return .init(image: self.icon, titleText: self.title)
    }
}
