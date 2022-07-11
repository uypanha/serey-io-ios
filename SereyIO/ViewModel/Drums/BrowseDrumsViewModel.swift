//
//  BrowseDrumsViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 21/6/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class BrowseDrumsViewModel: BaseViewModel, CollectionMultiSectionsProviderModel, InfiniteNetworkProtocol, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case itemSelected(IndexPath)
    }
    
    enum ViewToPresent {
        case postDrumViewController
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
   
    let drums: BehaviorRelay<[PostModel]>
    let cells: BehaviorRelay<[SectionItem]>
    
    var downloadDisposeBag: DisposeBag
    let canDownloadMorePages: BehaviorRelay<Bool>
    let isDownloading: BehaviorRelay<Bool>
    let isRefresh: BehaviorRelay<Bool>
    var pageModel: PaginationRequestModel
    let drumsService: DrumsService
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.downloadDisposeBag = .init()
        self.canDownloadMorePages = .init(value: true)
        self.isDownloading = .init(value: false)
        self.isRefresh = .init(value: true)
        self.pageModel = .init()
        
        self.drums = .init(value: [])
        self.cells = .init(value: [])
        self.drumsService = .init()
        super.init()
        
        setUpRxObservers()
    }
}

extension BrowseDrumsViewModel {
    
    func downloadData() {
        if self.canDownloadMore() && !self.isDownloading.value {
            self.isDownloading.accept(true)
            self.fetchAllDrums()
        }
    }
    
    private func fetchAllDrums() {
        self.drumsService.fetchAllDrums(self.pageModel)
            .asObservable()
            .subscribe(onNext: { [weak self] data in
                self?.isDownloading.accept(false)
                self?.update(data)
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                self?.shouldPresentError(ErrorHelper.prepareError(error: error))
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension BrowseDrumsViewModel {
    
    private func update(_ data: [PostModel]) {
        var drums = self.drums.value
        
        if self.isRefresh.value {
            self.isRefresh.accept(false)
            drums.removeAll()
        }
        
        drums.append(contentsOf: data)
        self.canDownloadMorePages.accept(data.count >= Constants.limitPerPage)
        self.pageModel.offset = data.count + drums.count
        
        self.drums.accept(drums)
    }
    
    private func prepareCells() -> [SectionItem] {
        var items: [CellViewModel] = []
        
        items.append(PostDrumsCellViewModel())
        items.append(contentsOf: self.drums.value.map { DrumsPostCellViewModel($0) })
        
        if self.canDownloadMore() {
            let count: Int = !self.drums.value.isEmpty ? 0 : Int.random(in: (3..<6))
            items.append(contentsOf: (0...count).map { _ in DrumsPostCellViewModel(true) })
        }
        
        return [.init(items: items)]
    }
}

// MARK: - Action Handlers
extension BrowseDrumsViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let _ = self.item(at: indexPath) as? PostDrumsCellViewModel {
            self.shouldPresent(.postDrumViewController)
        }
    }
}

// MARK: - SetUp RxObservers
extension BrowseDrumsViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.drums.asObservable()
            .map { _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indexPath):
                    self?.handleItemSelected(indexPath)
                }
            }) ~ self.disposeBag
    }
}
