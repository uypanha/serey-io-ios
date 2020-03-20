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
    
    let postType: BehaviorRelay<DiscussionType>
    let discussions: BehaviorRelay<[PostModel]>
    let selectedCategory: BehaviorRelay<DiscussionCategoryModel?>
    
    let cells: BehaviorRelay<[SectionItem]>
    let emptyOrError: BehaviorSubject<EmptyOrErrorViewModel?>
    
    let discussionService: DiscussionService
    let canDownloadMorePages: BehaviorRelay<Bool>
    var isRefresh: Bool = true
    lazy var pageModel: QueryDiscussionsBy = QueryDiscussionsBy()
    lazy var downloadDisposeBag: DisposeBag = DisposeBag()
    lazy var isDownloading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    init(_ type: DiscussionType, _ authorName: String? = nil) {
        self.cells = BehaviorRelay(value: [])
        self.emptyOrError = BehaviorSubject(value: nil)
        self.discussions = BehaviorRelay(value: [])
        self.selectedCategory = BehaviorRelay(value: nil)
        self.postType = BehaviorRelay(value: type)
        self.discussionService = DiscussionService()
        self.canDownloadMorePages = BehaviorRelay(value: true)
        super.init()
        
        pageModel.start_author = authorName
        setUpRxObservers()
    }
    
    open func prepareEmptyViewModel() -> EmptyOrErrorViewModel {
        let title = "No Post Yet!"
        let emptyMessage = "Your post will be shown here after you\nmade a post."
        return EmptyOrErrorViewModel(withErrorEmptyModel: EmptyOrErrorModel(withEmptyTitle: title, emptyDescription: emptyMessage, iconImage: R.image.emptyPost()))
    }
    
    open func prepareEmptyViewModel(_ erroInfo: ErrorInfo) -> EmptyOrErrorViewModel {
        return EmptyOrErrorViewModel(withErrorEmptyModel: EmptyOrErrorModel(withErrorInfo: erroInfo, actionTitle: "Try again", actionCompletion: { [weak self] in
            self?.downloadData()
        }))
    }
}

// MARK: - Networks
extension BasePostViewModel {
    
    func downloadData() {
        if !self.isDownloading.value && self.canDownloadMore() {
            self.isDownloading.accept(true)
            fetchDiscussions()
        }
    }
    
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
}

// MARK: - Preparations & Tools
extension BasePostViewModel {
    
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
    
    fileprivate func prepareCells(_ discussions: [PostModel], _ error: Bool) -> [SectionItem] {
        var cells: [CellViewModel] = []
        if let selectedCategory = self.selectedCategory.value {
            cells.append(FilteredCategoryCellViewModel(selectedCategory).then { [weak self] in
                self?.setUpFilterCellObservers($0)
            })
        }
        
        cells.append(contentsOf: discussions.map { PostCellViewModel($0) })
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
        
//        self.isDownloading.asObservable()
//            .map { _ in self.discussions.value }
//            .map { self.prepareCells($0) }
//            ~> self.cells
//            ~ self.disposeBag
        
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
