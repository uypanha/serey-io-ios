//
//  DrumDetailViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 20/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class DrumDetailViewModel: BaseViewModel,
                           DownloadStateNetworkProtocol,
                           CollectionMultiSectionsProviderModel,
                           ShouldReactToAction,
                           ShouldPresent {
    
    enum Action {
        case didBeginToComment
    }
    
    enum ViewToPresent {
        case signInViewController
        case drumDetailViewController(DrumDetailViewModel)
        case voteDialogController(VoteDialogViewModel)
        case downVoteDialogController(DownvoteDialogViewModel)
        case bottomListViewController(BottomListMenuViewModel)
        case mediaPreviewViewController(MediaPreviewViewModel)
        case postDrumViewController(PostDrumViewModel)
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let cells: BehaviorRelay<[SectionItem]>
    
    let author: String
    let permlink: String
    let drum: BehaviorRelay<DrumModel?>
    let replies: BehaviorRelay<[PostModel]>
    
    let drumDetailCellModel: DrumsPostCellViewModel
    let commentViewModel: CommentTextViewModel
    
    let isDownloading: BehaviorRelay<Bool>
    let drumService: DrumsService
    let discussionService: DiscussionService
    let shouldCommentFocus: Bool
    let redrummer: String?
    
    init(author: String, permlink: String, comment: Bool = false, redrummer: String? = nil) {
        self.redrummer = redrummer
        self.shouldCommentFocus = comment
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.cells = .init(value: [])
        self.drum = .init(value: nil)
        self.replies = .init(value: [])
        
        self.author = author
        self.permlink = permlink
        
        self.drumDetailCellModel = .init(nil)
        self.commentViewModel = .init()
        self.drumService = .init()
        self.discussionService = .init()
        self.isDownloading = .init(value: false)
        super.init()
        
        setUpRxObservers()
    }
    
    convenience init(_ drum: DrumModel, comment: Bool = false) {
        self.init(author: drum.author, permlink: drum.permlink, comment: comment, redrummer: drum.redrummer)

        self.drum.accept(drum)
        self.drumDetailCellModel.update(drum: drum)
    }
}

// MARK: - Networks
extension DrumDetailViewModel {
    
    func downloadData() {
        if !self.isDownloading.value {
            self.isDownloading.accept(true)
            self.fetchDrumDetail()
        }
    }
    
    func fetchDrumDetail() {
        self.drumService.fetchDrumDetail(author: self.author, permlink: self.permlink)
            .subscribe(onNext: { [weak self] data in
                let drum = data.content
                drum.redrummer = self?.redrummer
                self?.isDownloading.accept(false)
                self?.drum.accept(drum)
                self?.replies.accept(data.replies)
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                self?.shouldPresentError(ErrorHelper.prepareError(error: error))
            }) ~ self.disposeBag
    }
    
    internal func submitComment(_ comment: String) {
        let submitCommentModel = self.prepareSubmitCommentModel(comment)
        self.commentViewModel.isUploading.onNext(true)
        self.discussionService.submitComment(submitCommentModel)
            .subscribe(onNext: { [weak self] _ in
                self?.commentViewModel.isUploading.onNext(false)
                self?.fetchDrumDetail()
                self?.commentViewModel.clearInput()
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                self?.commentViewModel.isUploading.onNext(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    internal func upVote(_ permlink: String, author: String, _ weight: Int, _ isVoting: BehaviorSubject<VotedType?>) {
        isVoting.onNext(.upvote)
        self.discussionService.upVote(permlink, author: author, weight: weight)
            .subscribe(onNext: { [weak self] _ in
                self?.fetchDrumDetail()
                isVoting.onNext(nil)
            }, onError: { [weak self] error in
                isVoting.onNext(nil)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    internal func downVote(_ permlink: String, author: String, _ votedType: VotedType, _ isVoting: BehaviorSubject<VotedType?>) {
        isVoting.onNext(votedType)
        self.discussionService.downVote(permlink, author: author)
            .subscribe(onNext: { [weak self] _ in
                self?.fetchDrumDetail()
                isVoting.onNext(nil)
            }, onError: { [weak self] error in
                isVoting.onNext(nil)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    internal func prepareSubmitCommentModel(_ comment: String) -> SubmitCommentModel {
        let permlink = self.drum.value?.permlink ?? ""
        let author = self.drum.value?.author ?? ""
        let title = self.postTitle()
        let category = self.drum.value?.categories?.first ?? ""
        
        return SubmitCommentModel(parentAuthor: author, parentPermlink: permlink, title: title, body: comment, mainCategory: category)
    }
    
    internal func redrum(_ drum: DrumModel) {
        self.drumService.redrum(author: drum.author, permlink: drum.permlink)
            .subscribe(onNext: { [weak self] data in
                drum.redrummers.append(AuthData.shared.username ?? "")
//                self?.update(drum: drum)
                self?.fetchDrumDetail()
            }, onError: { [weak self] error in
                self?.shouldPresentError(ErrorHelper.prepareError(error: error))
            }) ~ self.disposeBag
    }
    
    internal func undoRedrum(_ drum: DrumModel) {
        self.drumService.undoRedrum(author: drum.author, permlink: drum.permlink)
            .subscribe(onNext: { [weak self] data in
                self?.fetchDrumDetail()
//                self?.removeDrum(with: drum.author, permlink: drum.permlink, redrummer: AuthData.shared.username ?? "")
//                self?.removeRedrum(with: drum.author, permlink: drum.permlink)
            }, onError: { [weak self] error in
                self?.shouldPresentError(ErrorHelper.prepareError(error: error))
            }) ~ self.disposeBag
    }
    
    internal func postTitle() -> String {
        return self.drum.value?.title ?? ""
    }
}

// MARK: - Preparations & Tools
private extension DrumDetailViewModel {
    
    func prepareCells() -> [SectionItem] {
        var items: [CellViewModel] = self.replies.value.map { DrumReplyCellViewModel(reply: $0).then {
            self.setUpReplyCellObservers($0)
        } }
        var repliesHeader: String? = items.isEmpty ? nil : "Replies"
        if self.isDownloading.value {
            if items.isEmpty {
                repliesHeader = "Replies"
                items.append(contentsOf: (0..<4).map { _ in DrumReplyCellViewModel() })
            }
        } else {
            items.append(NoMorePostCellViewModel("You reach the end"))
        }
        return [.init(model: .init(header: repliesHeader),items: items)]
    }
}

// MARK: - Action Handlers
fileprivate extension DrumDetailViewModel {
    
    func handleDrumActionPressed(_ drum: DrumModel, action: DrumsPostCellViewModel.DrumAction) {
        if !AuthData.shared.isUserLoggedIn {
            self.shouldPresent(.signInViewController)
            return
        }
        
        switch action {
        case .redrum:
            self.handleRedrumPressed(drum)
        case .comment:
            break
        case .vote(let voteType, let isVoting):
            if let _ = voteType {
                // Undo Voting
                self.handleDownVote(.upvotePost, drum.permlink, drum.author, isVoting)
            } else {
                // Upvote
                self.handleUpvote(.article, drum.permlink, drum.author, isVoting)
            }
        }
    }
    
    func handleReplyDrumActionPressed(_ comment: PostModel, action: DrumsPostCellViewModel.DrumAction) {
        if !AuthData.shared.isUserLoggedIn {
            self.shouldPresent(.signInViewController)
            return
        }
        
        switch action {
        case .comment:
            break
        case .vote(let voteType, let isVoting):
            if let _ = voteType {
                // Undo Voting
                self.handleDownVote(.upvotePost, comment.permlink, comment.author, isVoting)
            } else {
                // Upvote
                self.handleUpvote(.article, comment.permlink, comment.author, isVoting)
            }
        default:
            break
        }
    }
    
    func handleUpvote(_ voteType: VotePostType, _ permlink: String, _ author: String, _ isVoting: BehaviorSubject<VotedType?>) {
        if author == AuthData.shared.username {
            self.shouldPresentError(ErrorHelper.preparePredefineError(.voteOnYourOwnPost))
            return
        }
        
        let voteDialogViewModel = VoteDialogViewModel(type: voteType == .comment ? .upVoteComment : .upvoteDrum)
        voteDialogViewModel.shouldConfirm
            .subscribe(onNext: { [weak self] weight in
                self?.upVote(permlink, author: author, weight, isVoting)
            }) ~ voteDialogViewModel.disposeBag
        self.shouldPresent(.voteDialogController(voteDialogViewModel))
    }
    
    func handleDownVote(_ downvoteType: DownvoteDialogViewModel.DownVoteType, _ permlink: String, _ author: String, _ isVoting: BehaviorSubject<VotedType?>) {
        let downvoteViewModel = DownvoteDialogViewModel(downvoteType)
        downvoteViewModel.shouldConfirm
            .subscribe(onNext: { [weak self] _ in
                let votedType : VotedType = (downvoteType == .upVoteComment || downvoteType == .upvotePost) ? .upvote : .flag
                self?.downVote(permlink, author: author, votedType, isVoting)
            }) ~ downvoteViewModel.disposeBag
        self.shouldPresent(.downVoteDialogController(downvoteViewModel))
    }
    
    func handleQuotedDrumPressed(_ drum: DrumModel) {
        if let author = drum.postAuthor {
            let viewModel = DrumDetailViewModel(author: author, permlink: drum.postPermlink ?? "", redrummer: drum.redrummer)
            self.shouldPresent(.drumDetailViewController(viewModel))
        }
    }
    
    func handleRedrumPressed(_ drum: DrumModel) {
        let cellOptions: [CellViewModel] = drum.prepareRedrumQuoteOptions().map { $0.cellModel }
        let bottomListViewModel = BottomListMenuViewModel(header: " ", cellOptions)
        bottomListViewModel.shouldSelectMenuItem.asObservable()
            .subscribe(onNext: { [weak self] item in
                if let item = item as? RedrumQuoteOptionCellViewModel {
                    self?.handleQuoteDrumOption(drum, option: item.option)
                }
            }) ~ bottomListViewModel.disposeBag
        self.shouldPresent(.bottomListViewController(bottomListViewModel))
    }
    
    func handleQuoteDrumOption(_ drum: DrumModel, option: RedrumQuoteOption) {
        switch option {
        case .redrum:
            self.redrum(drum)
        case .undoRedrum:
            self.undoRedrum(drum)
        case .quoteDrum:
            let postDrumViewModel = PostDrumViewModel(.quote, drum: drum)
            self.shouldPresent(.postDrumViewController(postDrumViewModel))
        }
    }
}

// MARK: - SetUp RxObservers
private extension DrumDetailViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
        setUpDrumPostCellObservers(self.drumDetailCellModel)
    }
    
    func setUpContentChangedObservers() {
        self.drum.asObservable()
            .subscribe(onNext: { [weak self] drum in
                self?.drumDetailCellModel.update(drum: drum)
            }) ~ self.disposeBag
        
        self.replies.asObservable()
            .map { _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
        
        self.isDownloading.asObservable()
            .filter { $0 }
            .map { _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
        
        self.commentViewModel.shouldSendComment.asObservable()
            .subscribe(onNext: { [weak self] text in
                self?.submitComment(text)
            }) ~ self.disposeBag
    }
    
    func setUpDrumPostCellObservers(_ cellModel: DrumsPostCellViewModel) {
        cellModel.didProfilePressed.asObservable()
            .subscribe(onNext: { [weak self] author in
//                self?.handleOnProfilePressed(author)
            }) ~ cellModel.disposeBag
        
        cellModel.didQuotedPostPressed.asObservable()
            .subscribe(onNext: { [weak self] drum in
                self?.handleQuotedDrumPressed(drum)
            }) ~ cellModel.disposeBag
        
        cellModel.didPostActionPressed.asObservable()
            .subscribe(onNext: { [weak self] action, drum in
                self?.handleDrumActionPressed(drum, action: action)
            }) ~ cellModel.disposeBag
        
        cellModel.shouldPreviewImages.asObservable()
            .map { ViewToPresent.mediaPreviewViewController($0) }
            .bind(to: self.shouldPresentSubject)
            ~ cellModel.disposeBag
    }
    
    func setUpReplyCellObservers(_ cellModel: DrumReplyCellViewModel) {
        cellModel.didPostActionPressed.asObservable()
            .subscribe(onNext: { [weak self] action, reply in
                self?.handleReplyDrumActionPressed(reply, action: action)
            }) ~ cellModel.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .didBeginToComment:
                    if !AuthData.shared.isUserLoggedIn {
                        self?.shouldPresent(.signInViewController)
                    }
                }
            }) ~ self.disposeBag
    }
}
