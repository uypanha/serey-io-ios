//
//  BasePostViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/14/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources
import Then

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
    let isRefresh: BehaviorRelay<Bool>
    var shouldRefresh: Bool = false
    var currentCountry: String?
    
    lazy var pageModel: PaginationRequestModel = PaginationRequestModel()
    lazy var downloadDisposeBag: DisposeBag = DisposeBag()
    lazy var isDownloading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    init(_ type: DiscussionType, _ selectedCategory: BehaviorRelay<DiscussionCategoryModel?>) {
        self.title = type.title
        self.cells = .init(value: [])
        self.emptyOrError = .init(value: nil)
        self.discussions = .init(value: [])
        self.selectedCategory = selectedCategory
        self.postType = .init(value: type)
        self.discussionService = .init()
        self.canDownloadMorePages = .init(value: true)
        self.isRefresh = .init(value: true)
        self.endRefresh = .init(value: false)
        self.currentCountry = PreferenceStore.shared.currentUserCountry
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
        
        cellModel.shouldSharePost.asObservable()
            .subscribe(onNext: { [weak self] (url, content) in
                self?.onSharePostPressed(with: url, content: content)
            }) ~ self.disposeBag
    }
    
    open func prepareCells(_ discussions: [PostModel], _ error: Bool) -> [SectionItem] {
        var cells: [CellViewModel] = []
        if let selectedCategory = self.selectedCategory.value {
            cells.append(FilteredCategoryCellViewModel(selectedCategory).then { [weak self] in
                self?.setUpFilterCellObservers($0)
            })
        }
        
        cells.append(contentsOf: discussions.map {
            if $0.isHidden {
                return UndoHiddenPostCellViewModel($0).then {
                    setUpHiddenPostCellObservers($0)
                }
            } else {
                return PostCellViewModel($0).then {
                    setUpPostCellViewModel($0)
                }
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
    
    func validateCountry() {
        if self.currentCountry != PreferenceStore.shared.currentUserCountry {
            self.currentCountry = PreferenceStore.shared.currentUserCountry
            var _self = self
            _self.reset()
        }
    }
    
    internal func onMorePressed(of postModel: PostModel) {}
    
    internal func onCategoryPressed(of postModel: PostModel) {}
    
    internal func onProfilePressed(of postModel: PostModel) {}
    
    internal func onSharePostPressed(with url: URL, content: String) {}
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
                NotificationDispatcher.sharedInstance.dispatch(.postUpdated(permlink: response.content.permlink, author: response.content.author, post: response.content))
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    internal func upVote(_ post: PostModel, _ weight: Int, _ isVoting: BehaviorSubject<VotedType?>) {
        isVoting.onNext(.upvote)
        self.discussionService.upVote(post.permlink, author: post.author, weight: weight)
            .subscribe(onNext: { [weak self] _ in
                self?.fetchPostDetial(post.permlink, post.author)
                isVoting.onNext(nil)
            }, onError: { [weak self] error in
                isVoting.onNext(nil)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    internal func flag(_ post: PostModel, _ weight: Int, _ isVoting: BehaviorSubject<VotedType?>) {
        isVoting.onNext(.flag)
        self.discussionService.flag(post.permlink, author: post.author, weight: weight)
            .subscribe(onNext: { [weak self] _ in
                self?.fetchPostDetial(post.permlink, post.author)
                isVoting.onNext(nil)
            }, onError: { [weak self] error in
                isVoting.onNext(nil)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    internal func downVote(_ post: PostModel, _ votedType: VotedType, _ isVoting: BehaviorSubject<VotedType?>) {
        isVoting.onNext(votedType)
        self.discussionService.downVote(post.permlink, author: post.author)
            .subscribe(onNext: { [weak self] _ in
                self?.fetchPostDetial(post.permlink, post.author)
                isVoting.onNext(nil)
            }, onError: { [weak self] error in
                isVoting.onNext(nil)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    internal func hidePost(_ post: PostModel) {
        self.discussionService.hidePost(with: post.id)
            .subscribe(onNext: { [weak self] data in
                var post = post
                post.isHidden = true
                self?.updatePost(post)
            }, onError: { [weak self] error in
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    internal func unhidePost(_ post: PostModel) {
        self.discussionService.unhidePost(with: post.id)
            .subscribe(onNext: { [weak self] data in
                var post = post
                post.isHidden = false
                self?.updatePost(post)
            }, onError: { [weak self] error in
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension BasePostViewModel {
    
    internal func updatePost(_ post: PostModel) {
        var posts = self.discussions.value
        if let indexToUpdate = posts.index(where: { $0.permlink == post.permlink && $0.author == post.author }) {
            posts[indexToUpdate] = post
        }
        self.discussions.accept(posts)
    }
    
    fileprivate func updateData(_ data: [PostModel]) {
        var discussions = self.discussions.value
        
        if self.isRefresh.value {
            discussions.removeAll()
            self.isRefresh.accept(false)
        }
        
        if data.isEmpty || pageModel.limit > data.count {
            canDownloadMorePages.accept(false)
        }
        if data.count > 0 {
            self.pageModel.offset = data.count + self.discussions.value.count
        }
        
        discussions.append(contentsOf: data)
        self.discussions.accept(discussions)
    }
    
    internal func removePost(permlink: String, author: String) {
        var posts = self.discussions.value
        if let indexToRemove = posts.index(where: { $0.permlink == permlink && $0.author == author }) {
            posts.remove(at: indexToRemove)
        }
        self.discussions.accept(posts)
    }
    
//    func setCategory(_ category: DiscussionCategoryModel?) {
//        self.selectedCategory.accept(category)
//    }
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
    
    func setUpHiddenPostCellObservers(_ cellModel: UndoHiddenPostCellViewModel) {
        cellModel.shouldUnhidePost.asObservable()
            .subscribe(onNext: { [weak self] post in
                self?.unhidePost(post)
            }) ~ cellModel.disposeBag
    }
}
