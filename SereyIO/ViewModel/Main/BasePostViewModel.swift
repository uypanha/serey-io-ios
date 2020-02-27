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
    let discussions: BehaviorRelay<[DiscussionModel]>
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
        self.postType = BehaviorRelay(value: type)
        self.discussionService = DiscussionService()
        self.canDownloadMorePages = BehaviorRelay(value: true)
        super.init()
        
        setUpRxObservers()
    }
    
    open func prepareEmptyViewModel() -> EmptyOrErrorViewModel {
        let title = "No Post Yet!"
        let emptyMessage = "Your post will be shown here after you\nmade a post."
        return EmptyOrErrorViewModel(withErrorEmptyModel: EmptyOrErrorModel(withEmptyTitle: title, emptyDescription: emptyMessage, iconImage: R.image.emptyPost()))
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
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension BasePostViewModel {
    
    fileprivate func updateData(_ data: [DiscussionModel]) {
        var discussions = self.discussions.value
        
        if self.isRefresh {
            discussions.removeAll()
            self.isRefresh = false
        }
        
        if data.count > 0 {
            self.pageModel.start_author = data.last?.authorName
            self.pageModel.start_permlink = data.last?.permlink
        }
        if pageModel.limit > data.count {
            canDownloadMorePages.accept(false)
        }
        
        discussions.append(contentsOf: data)
        self.discussions.accept(discussions)
    }
    
    fileprivate func prepareCells(_ discussions: [DiscussionModel]) -> [SectionItem] {
        let cells = discussions.map { _ in PostCellViewModel() }
        return [SectionItem(items: cells)]
    }
}

// MARK: - SetUp RxObservers
fileprivate extension BasePostViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.discussions.asObservable()
            .map { self.prepareCells($0) }
            ~> self.cells
            ~ self.disposeBag
        
        self.cells.asObservable()
            .subscribe(onNext: { [unowned self] cells in
                if cells.isEmpty {
                    self.emptyOrError.onNext(self.prepareEmptyViewModel())
                }
            }) ~ self.disposeBag
    }
}

// MARK: - QueryDiscussionsBy
extension QueryDiscussionsBy: PaginationRequestProtocol {
    
    mutating func reset() {
        self.start_permlink = nil
        self.start_author = nil
    }
}
