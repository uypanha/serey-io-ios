//
//  BasePostViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/14/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class BasePostViewModel: BaseCellViewModel, CollectionMultiSectionsProviderModel, InfiniteNetworkProtocol {
    
    let title: String
    let postType: BehaviorRelay<DiscussionType>
    let discussions: BehaviorRelay<[PostModel]>
    let selectedCategory: BehaviorRelay<DiscussionCategoryModel?>
    
    let cells: BehaviorRelay<[SectionItem]>
    let emptyOrError: BehaviorSubject<EmptyOrErrorViewModel?>
    let endRefresh: BehaviorSubject<Bool>
    
    var discussionService: DiscussionService
    let canDownloadMorePages: BehaviorRelay<Bool>
    var isRefresh: Bool = true
    var shouldRefresh: Bool = false
    lazy var pageModel: QueryDiscussionsBy = QueryDiscussionsBy()
    lazy var downloadDisposeBag: DisposeBag = DisposeBag()
    lazy var isDownloading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    init(_ type: DiscussionType) {
        self.title = type.title
        self.cells = BehaviorRelay(value: [])
        self.emptyOrError = BehaviorSubject(value: nil)
        self.discussions = BehaviorRelay(value: [])
        self.selectedCategory = BehaviorRelay(value: nil)
        self.postType = BehaviorRelay(value: type)
        self.discussionService = DiscussionService()
        self.canDownloadMorePages = BehaviorRelay(value: true)
        self.endRefresh = BehaviorSubject(value: false)
        super.init()
        
        setUpRxObservers()
    }
    
    open func prepareEmptyViewModel() -> EmptyOrErrorViewModel {
        let title = R.string.post.noPostYet.localized()
        let emptyMessage = self.postType.value.emptyMessage
        return EmptyOrErrorViewModel(withErrorEmptyModel: EmptyOrErrorModel(withEmptyTitle: title, emptyDescription: emptyMessage, iconImage: R.image.emptyPost()))
    }
    
    open func prepareEmptyViewModel(_ erroInfo: ErrorInfo) -> EmptyOrErrorViewModel {
        return EmptyOrErrorViewModel(withErrorEmptyModel: EmptyOrErrorModel(withErrorInfo: erroInfo, actionTitle: R.string.common.tryAgain.localized(), actionCompletion: { [unowned self] in
            self.downloadData()
            self.discussions.renotify()
        }))
    }
    
    open func downloadData() {
        if !self.isDownloading.value && self.canDownloadMore() {
            self.isDownloading.accept(true)
            fetchDiscussions()
        }
    }
    
    open func setUpPostCellViewModel(_ cellModel: PostCellViewModel) {
        cellModel.shouldShowMoreOption.asObservable()
            .subscribe(onNext: { [weak self] postModel in
                self?.onMorePressed(of: postModel)
            }) ~ cellModel.disposeBag
        
        cellModel.shouldShowPostsByCategory.asObservable()
            .subscribe(onNext: { [weak self] postModel in
                self?.onCategoryPressed(of: postModel)
            }) ~ cellModel.disposeBag
        
        cellModel.shouldShowAuthorProfile.asObservable()
            .subscribe(onNext: { [weak self] postModel in
                self?.onProfilePressed(of: postModel)
            }) ~ cellModel.disposeBag
    }
    
    internal func onMorePressed(of postModel: PostModel) {}
    
    internal func onCategoryPressed(of postModel: PostModel) {}
    
    internal func onProfilePressed(of postModel: PostModel) {}
}

// MARK: - Networks
extension BasePostViewModel {
    
    func fetchDiscussions() {
        self.discussionService.getDiscussionList(self.postType.value, self.pageModel)
            .subscribe(onNext: { [weak self] discussions in
                self?.isDownloading.accept(false)
                self?.updateData(discussions)
            }, onError: { [unowned self] error in
                self.isDownloading.accept(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self.cells.accept(self.prepareCells(self.discussions.value, true))
                self.shouldPresentError(errorInfo)
            }) ~ self.downloadDisposeBag
    }
    
    private func fetchPostDetial(_ permlink: String, _ author: String) {
        self.discussionService.getPostDetail(permlink: permlink, authorName: author)
            .subscribe(onNext: { response in
                NotificationDispatcher.sharedInstance.dispatch(.postUpdated(permlink: response.content.permlink, author: response.content.authorName, post: response.content))
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    internal func upVote(_ post: PostModel, _ weight: Int, _ isVoting: BehaviorSubject<VotedType?>) {
        isVoting.onNext(.upvote)
        self.discussionService.upVote(post.permlink, author: post.authorName, weight: weight)
            .subscribe(onNext: { [weak self] _ in
                self?.fetchPostDetial(post.permlink, post.authorName)
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
                self?.fetchPostDetial(post.permlink, post.authorName)
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
                self?.fetchPostDetial(post.permlink, post.authorName)
                isVoting.onNext(nil)
            }, onError: { [weak self] error in
                isVoting.onNext(nil)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension BasePostViewModel {
    
    internal func updatePost(_ post: PostModel) {
        var posts = self.discussions.value
        if let indexToUpdate = posts.index(where: { $0.permlink == post.permlink && $0.authorName == post.authorName }) {
            posts[indexToUpdate] = post
        }
        self.discussions.accept(posts)
    }
    
    fileprivate func updateData(_ data: [PostModel]) {
        var discussions = self.discussions.value
        
        if self.isRefresh {
            discussions.removeAll()
            self.isRefresh = false
        }
        
        if data.count > 0 {
            self.pageModel.start_author = data.last?.authorName
            self.pageModel.start_permlink = data.last?.permlink
        }
        if data.isEmpty || pageModel.limit > data.count {
            canDownloadMorePages.accept(false)
        }
        
        discussions.append(contentsOf: data)
        self.discussions.accept(discussions)
    }
    
    internal func removePost(permlink: String, author: String) {
        var posts = self.discussions.value
        if let indexToRemove = posts.index(where: { $0.permlink == permlink && $0.authorName == author }) {
            posts.remove(at: indexToRemove)
        }
        self.discussions.accept(posts)
    }
    
    fileprivate func prepareCells(_ discussions: [PostModel], _ error: Bool) -> [SectionItem] {
        var cells: [CellViewModel] = []
        if let selectedCategory = self.selectedCategory.value {
            cells.append(FilteredCategoryCellViewModel(selectedCategory).then { [weak self] in
                self?.setUpFilterCellObservers($0)
            })
        }
        
        cells.append(contentsOf: discussions.map {
            PostCellViewModel($0).then {
                setUpPostCellViewModel($0)
            }
        })
        
        if self.canDownloadMore() {
            let loadingCells = error ? nil : !discussions.isEmpty ? (0...0) : (0...3)
            if let loadingCells = loadingCells {
                cells.append(contentsOf: loadingCells.map { _ in PostCellViewModel(true) })
            }
        }
        return [SectionItem(items: cells)]
    }
    
    func setCategory(_ category: DiscussionCategoryModel?) {
        self.selectedCategory.accept(category)
    }
}

// MARK: - SetUp RxObservers
fileprivate extension BasePostViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.discussions.asObservable()
            .map { self.prepareCells($0, false) }
            ~> self.cells
            ~ self.disposeBag
        
        self.discussions.asObservable()
            .subscribe(onNext: { [unowned self] discussions in
                if discussions.isEmpty && !self.isDownloading.value && !self.canDownloadMore() {
                    self.emptyOrError.onNext(self.prepareEmptyViewModel())
                }
            }) ~ self.disposeBag
        
        self.isDownloading.asObservable()
            .filter { !$0 }
            .map { !$0 }
            ~> self.endRefresh
            ~ self.disposeBag
        
        self.selectedCategory.asObservable()
            .skip(1)
            .subscribe(onNext: { [weak self] selectedCategory in
                self?.pageModel.tag = selectedCategory?.name
                self?.reset()
                self?.discussions.accept([])
            }) ~ self.disposeBag
    }
    
    func setUpFilterCellObservers(_ cellModel: FilteredCategoryCellViewModel) {
        cellModel.shouldRemoveFilter.asObservable()
            .map { _ in return nil }
            ~> self.selectedCategory
            ~ cellModel.disposeBag
    }
}

// MARK: - QueryDiscussionsBy
extension QueryDiscussionsBy: PaginationRequestProtocol {
    
    mutating func reset() {
        self.start_permlink = nil
        self.start_author = nil
    }
}
