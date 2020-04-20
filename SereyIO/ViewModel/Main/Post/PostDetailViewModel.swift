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

class PostDetailViewModel: BaseCellViewModel, ShouldReactToAction, ShouldPresent, CollectionMultiSectionsProviderModel, DownloadStateNetworkProtocol {
    
    enum Action {
        case morePressed
        case upVotePressed(VotePostType, PostModel)
        case flagPressed(VotePostType, PostModel)
        case refresh
        case replyCommentPressed(CommentCellViewModel)
    }
    
    enum ViewToPresent {
        case moreDialogController(BottomListMenuViewModel)
        case editPostController(CreatePostViewModel)
        case deletePostDialog(confirm: () -> Void)
        case replyComment(ReplyCommentTableViewModel)
        case voteDialogController(VoteDialogViewModel)
        case signInViewController
        case loading(Bool)
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let cells: BehaviorRelay<[SectionItem]>
    
    let permlink: BehaviorRelay<String>
    let authorName: BehaviorRelay<String>
    let discussion: BehaviorRelay<PostModel?>
    let replies: BehaviorRelay<[PostModel]>
    
    let postViewModel: BehaviorRelay<PostDetailCellViewModel?>
    let commentPostViewModel: BehaviorRelay<PostCommentViewModel?>
    let sereyValueText: BehaviorSubject<String>
    let isMoreHidden: BehaviorSubject<Bool>
    let endRefresh: BehaviorSubject<Bool>
    
    let discussionService: DiscussionService
    let isDownloading: BehaviorRelay<Bool>
    
    init(_ permlink: String, _ authorName: String) {
        self.permlink = BehaviorRelay(value: permlink)
        self.authorName = BehaviorRelay(value: authorName)
        self.discussion = BehaviorRelay(value: nil)
        self.replies = BehaviorRelay(value: [])
        
        self.postViewModel = BehaviorRelay(value: nil)
        self.commentPostViewModel = BehaviorRelay(value: nil)
        self.sereyValueText = BehaviorSubject(value: "")
        self.isMoreHidden = BehaviorSubject(value: true)
        self.endRefresh = BehaviorSubject(value: true)
        
        self.cells = BehaviorRelay(value: [])
        self.discussionService = DiscussionService()
        self.isDownloading = BehaviorRelay(value: false)
        super.init()
        
        setUpRxObservers()
    }
    
    convenience init(_ discussion: PostModel) {
        self.init(discussion.permlink, discussion.authorName)
        self.discussion.accept(discussion)
    }
}

// MARK: - Networks
extension PostDetailViewModel {
    
    func downloadData() {
        if !self.isDownloading.value {
            self.isDownloading.accept(true)
            self.fetchPostDetial()
        }
    }
    
    private func fetchPostDetial() {
        self.replies.renotify()
        self.discussionService.getPostDetail(permlink: self.permlink.value, authorName: self.authorName.value)
            .subscribe(onNext: { [weak self] response in
                self?.isDownloading.accept(false)
                self?.replies.accept(response.replies)
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    private func submitComment(_ comment: String) {
        let submitCommentModel = self.prepareSubmitCommentModel(comment)
        self.commentPostViewModel.value?.isUploading.onNext(true)
        self.discussionService.submitComment(submitCommentModel)
            .subscribe(onNext: { [weak self] _ in
                self?.fetchPostDetial()
                self?.commentPostViewModel.value?.clearInput()
                self?.commentPostViewModel.value?.isUploading.onNext(false)
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                self?.commentPostViewModel.value?.isUploading.onNext(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    private func upVote(_ post: PostModel, _ weight: Int) {
        self.discussionService.upVote(post.permlink, author: post.authorName, weight: weight)
            .subscribe(onNext: { [weak self] _ in
                self?.fetchPostDetial()
            }, onError: { [weak self] error in
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    private func flag(_ post: PostModel, _ weight: Int) {
        self.discussionService.flag(post.permlink, author: post.authorName, weight: weight)
            .subscribe(onNext: { [weak self] _ in
                self?.fetchPostDetial()
            }, onError: { [weak self] error in
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    private func deletePost() {
        if let post = self.discussion.value {
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

// MARK: - Preparations & Tools
extension PostDetailViewModel {
    
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
    
    enum VotePostType {
        case comment
        case article
    }
    
    fileprivate func notifyDataChanged(_ data: PostModel?) {
        let postDetailViewModel = data == nil ? PostDetailCellViewModel(true) : PostDetailCellViewModel(data)
        let commentPostViewModel = data == nil ? PostCommentViewModel(true) : PostCommentViewModel(data).then {
            self.setUpCommentViewModelObservers($0)
        }
        self.postViewModel.accept(postDetailViewModel)
        self.commentPostViewModel.accept(commentPostViewModel)
        self.sereyValueText.onNext(data?.sereyValue ?? "")
        let isMorePresent = AuthData.shared.isUserLoggedIn ? data?.authorName == AuthData.shared.username : false
        self.isMoreHidden.onNext(!isMorePresent)
    }
    
    fileprivate func prepareCells(_ replies: [PostModel]) -> [SectionItem] {
        var cells: [CellViewModel] = []
        cells.append(contentsOf: replies.map { CommentCellViewModel($0).then { self.setUpCommentCellObservers($0) } })
        if self.isDownloading.value && replies.isEmpty {
            cells.append(contentsOf: (0...3).map { _ in CommentCellViewModel(true) })
        }
        return [SectionItem(items: cells)]
    }
    
    fileprivate func prepareSubmitCommentModel(_ comment: String) -> SubmitCommentModel {
        let permlink = self.discussion.value?.permlink ?? ""
        let author = self.discussion.value?.authorName ?? ""
        let title = self.discussion.value?.title ?? ""
        let category = self.discussion.value?.categoryItem.first ?? ""
        
        return SubmitCommentModel(parentAuthor: author, parentPermlink: permlink, title: title, body: comment, mainCategory: category)
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
            if let post = self.discussion.value {
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
        if let commentData = cellViewModel.discussion.value {
            if AuthData.shared.isUserLoggedIn {
                let replyCommentViewModel = ReplyCommentTableViewModel(commentData, title: self.discussion.value?.title ?? "")
                self.shouldPresent(.replyComment(replyCommentViewModel))
            } else {
                self.shouldPresent(.signInViewController)
            }
        }
    }
    
    func handleUpVotePressed(_ voteType: VotePostType, _ postModel: PostModel) {
        if AuthData.shared.isUserLoggedIn {
            let voteDialogViewModel = VoteDialogViewModel(100, type: voteType == .comment ? .upVoteComment : .upvotePost)
            voteDialogViewModel.shouldConfirm
                .subscribe(onNext: { [weak self] weight in
                    self?.upVote(postModel, weight)
                }) ~ voteDialogViewModel.disposeBag
            self.shouldPresent(.voteDialogController(voteDialogViewModel))
        } else {
            self.shouldPresent(.signInViewController)
        }
    }
    
    func handleFlagPressed(_ voteType: VotePostType, _ postModel: PostModel) {
        if AuthData.shared.isUserLoggedIn {
            let voteDialogViewModel = VoteDialogViewModel(100, type: voteType == .comment ? .downVoteComment : .downVotePost)
            voteDialogViewModel.shouldConfirm
                .subscribe(onNext: { [weak self] weight in
                    self?.flag(postModel, -weight)
                }) ~ voteDialogViewModel.disposeBag
            self.shouldPresent(.voteDialogController(voteDialogViewModel))
        } else {
            self.shouldPresent(.signInViewController)
        }
    }
}

// MARK: - SetUp RxObservers
extension PostDetailViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.discussion.asObservable()
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
                case .upVotePressed(let data):
                    self?.handleUpVotePressed(data.0, data.1)
                case .flagPressed(let data):
                    self?.handleFlagPressed(data.0, data.1)
                }
            }) ~ self.disposeBag
    }
    
    func setUpCommentViewModelObservers(_ viewModel: PostCommentViewModel) {
        viewModel.shouldUpVote.asObservable()
            .map { Action.upVotePressed(.article, $0) }
            ~> self.didActionSubject
            ~ viewModel.disposeBag
        
        viewModel.shouldFlag.asObservable()
            .map { Action.flagPressed(.article, $0) }
            ~> self.didActionSubject
            ~ viewModel.disposeBag
        
//        viewModel.shouldDownvote.asObservable()
//            .map {}
        
        viewModel.shouldComment.asObservable()
            .subscribe(onNext: { [weak self] comment in
                self?.submitComment(comment)
            }) ~ viewModel.disposeBag
    }
    
    func setUpCommentCellObservers(_ cellModel: CommentCellViewModel) {
        cellModel.shouldReplyComment
            .map { Action.replyCommentPressed($0) }
            ~> self.didActionSubject
            ~ self.disposeBag
        
        cellModel.shouldUpVoteComment
            .map { Action.upVotePressed(.comment, $0) }
            ~> self.didActionSubject
            ~ self.disposeBag
        
        cellModel.shouldFlagComment
            .map { Action.flagPressed(.comment, $0) }
            ~> self.didActionSubject
            ~ self.disposeBag
    }
}

// MARK: - PostMenuCellViewModel
class PostMenuCellViewModel: ImageTextCellViewModel {
    
    let type: PostDetailViewModel.PostMenu
    
    init(_ type: PostDetailViewModel.PostMenu) {
        self.type = type
        super.init(model: type.imageTextModel)
    }
}
