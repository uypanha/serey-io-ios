//
//  PostTableViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/6/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class PostTableViewModel: BasePostViewModel, ShouldReactToAction, ShouldPresent, ShouldRefreshProtocol {
    
    enum Action {
        case itemSelected(IndexPath)
        case refresh
        case upVotePressed(VotePostType, PostModel, BehaviorSubject<VotedType?>)
        case flagPressed(VotePostType, PostModel, BehaviorSubject<VotedType?>)
        case downVotePressed(DownvoteDialogViewModel.DownVoteType, PostModel, BehaviorSubject<VotedType?>)
    }
    
    enum ViewToPresent {
        case loading(Bool)
        case postDetailViewController(PostDetailViewModel)
        case moreDialogController(BottomListMenuViewModel)
        case editPostController(CreatePostViewModel)
        case deletePostDialog(confirm: () -> Void)
        case postsByCategoryController(PostTableViewModel)
        case userAccountController(UserAccountViewModel)
        case voteDialogController(VoteDialogViewModel)
        case downVoteDialogController(DownvoteDialogViewModel)
        case signInViewController
        case draftsViewController(DraftListViewModel)
        case reportPostController(ReportPostViewModel)
        case confirmViewController(ConfirmDialogViewModel)
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<PostTableViewModel.ViewToPresent>()
    
    override init(_ type: DiscussionType, _ selectedCategory: BehaviorRelay<DiscussionCategoryModel?>) {
        super.init(type, selectedCategory)
        
        setUpRxObservers()
        registerForNotifs()
    }
    
    func shouldRefreshData() {
        self.didAction(with: .refresh)
    }
    
    override func onMorePressed(of postModel: PostModel) {
        if AuthData.shared.isUserLoggedIn {
            let items: [PostMenu] = postModel.prepareOptionMenu()
            let bottomMenuViewModel = BottomListMenuViewModel(header: " ", items.map { $0.cellModel })
            
            bottomMenuViewModel.shouldSelectMenuItem.asObservable()
                .subscribe(onNext: { [weak self] item in
                    if let itemType = (item as? PostMenuCellViewModel)?.type {
                        self?.handleMenuPressed(itemType, postModel)
                    }
                }) ~ bottomMenuViewModel.disposeBag
            
            self.shouldPresent(.moreDialogController(bottomMenuViewModel))
        } else {
            self.shouldPresent(.signInViewController)
        }
    }
    
    override func onCategoryPressed(of postModel: PostModel) {
        switch self.postType.value {
        case .byCategoryId:
            return
        default:
            if let categoryId = postModel.categories?.first {
                let postTableViewModel = PostTableViewModel(.byCategoryId(categoryId), self.selectedCategory)
                self.shouldPresent(.postsByCategoryController(postTableViewModel))
            }
        }
    }
    
    override func onProfilePressed(of postModel: PostModel) {
        let userAccountViewModel = UserAccountViewModel(postModel.author)
        self.shouldPresent(.userAccountController(userAccountViewModel))
    }
    
    override func setUpPostCellViewModel(_ cellModel: PostCellViewModel) {
        super.setUpPostCellViewModel(cellModel)
        
        cellModel.shouldUpVote.asObservable()
            .map { Action.upVotePressed(.article, $0, cellModel.isVoting) }
            ~> self.didActionSubject
            ~ cellModel.disposeBag
        
        cellModel.shouldFlag.asObservable()
            .map { Action.flagPressed(.article, $0, cellModel.isVoting) }
            ~> self.didActionSubject
            ~ cellModel.disposeBag
        
        cellModel.shouldDownvote.asObservable()
            .map { Action.downVotePressed($0.0 == .flag ? .flagPost : .upvotePost, $0.1, cellModel.isVoting) }
            ~> self.didActionSubject
            ~ cellModel.disposeBag
    }
    
    func handleItemPressed(_ indexPath: IndexPath) {
        if let item = self.item(at: indexPath) as? PostCellViewModel {
            if let discussion = item.post.value {
                let viewModel = PostDetailViewModel(discussion)
                self.shouldPresent(.postDetailViewController(viewModel))
            }
        } else if self.item(at: indexPath) is DraftSavedCellViewModel {
            let viewModel = DraftListViewModel()
            self.shouldPresent(.draftsViewController(viewModel))
        }
    }
    
    deinit {
        unregisterFromNotifs()
    }
}

// MARK: - Networks
extension PostTableViewModel {
    
    private func deletePost(_ post: PostModel) {
        self.shouldPresent(.loading(true))
        self.discussionService.deletePost(post.author, post.permlink)
            .subscribe(onNext: { [weak self] _ in
                self?.shouldPresent(.loading(false))
                NotificationDispatcher.sharedInstance.dispatch(.postDeleted(permlink: post.permlink, author: post.author))
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Action Handlers
fileprivate extension PostTableViewModel {
    
    func handleMenuPressed(_ type: PostMenu, _ post: PostModel) {
        switch type {
        case .edit:
            let createPostViewModel = CreatePostViewModel(.edit(post))
            self.shouldPresent(.editPostController(createPostViewModel))
        case .delete:
            self.shouldPresent(.deletePostDialog(confirm: {
                self.deletePost(post)
            }))
        case .reportPost:
            self.shouldPresent(.reportPostController(.init(with: post)))
        case .hidePost:
            let title = "Hide this post?"
            let message = "You won’t see this post from \(post.author) in your feed."
            let action = ActionModel("Hide", style: .default) {
                self.hidePost(post)
            }
            let confirmDialogViewModel = ConfirmDialogViewModel(title: title, message: message, action: action)
            self.shouldPresent(.confirmViewController(confirmDialogViewModel))
        }
    }
    
    func handlePostUpdated(permlink: String, author: String, post: PostModel?) {
        if let post = post {
            updatePost(post)
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
}

// MARK: - SetUp RxObservers
fileprivate extension PostTableViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indexPath):
                    self?.handleItemPressed(indexPath)
                case .refresh:
                    self?.reset()
                    self?.discussions.renotify()
                case .upVotePressed(let type, let post, let votedType):
                    self?.handleUpVotePressed(type, post, votedType)
                case .flagPressed(let type, let post, let votedType):
                    self?.handleFlagPressed(type, post, votedType)
                case .downVotePressed(let type, let post, let votedType):
                    self?.handlDownvotePressed(type, post, votedType)
                }
            }) ~ self.disposeBag
    }
}

// MARK: - NotificationObserver
extension PostTableViewModel: NotificationObserver {
    
    func notificationReceived(_ notification: Notification) {
        guard let appNotif = notification.appNotification else { return }
        switch appNotif {
        case .postCreated:
            self.shouldRefresh = true
        case .postUpdated(let permlink, let author, let post):
            self.handlePostUpdated(permlink: permlink, author: author, post: post)
        case .postDeleted(let permlink, let author):
            self.removePost(permlink: permlink, author: author)
        case .userDidLogin, .userDidLogOut:
            self.discussionService = DiscussionService()
            self.discussions.renotify()
        default:
            break
        }
    }
}
