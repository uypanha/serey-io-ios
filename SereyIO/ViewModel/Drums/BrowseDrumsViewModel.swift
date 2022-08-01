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
import Then

class BrowseDrumsViewModel: BaseViewModel, CollectionMultiSectionsProviderModel, InfiniteNetworkProtocol, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case itemSelected(IndexPath)
    }
    
    enum ViewToPresent {
        case postDrumViewController
        case authorDrumListingViewController(BrowseDrumsViewModel)
        case drumDetailViewController(DrumDetailViewModel)
        case signInViewController
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
   
    let author: String?
    let containPostItem: Bool
    let drums: BehaviorRelay<[DrumModel]>
    let cells: BehaviorRelay<[SectionItem]>
    
    var downloadDisposeBag: DisposeBag
    let canDownloadMorePages: BehaviorRelay<Bool>
    let isDownloading: BehaviorRelay<Bool>
    let isRefresh: BehaviorRelay<Bool>
    var pageModel: PaginationRequestModel
    let drumsService: DrumsService
    
    init(author: String? = nil, containPostItem: Bool) {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.downloadDisposeBag = .init()
        self.canDownloadMorePages = .init(value: true)
        self.isDownloading = .init(value: false)
        self.isRefresh = .init(value: true)
        self.pageModel = .init()
        
        self.author = author
        self.containPostItem = containPostItem
        self.drums = .init(value: [])
        self.cells = .init(value: [])
        self.drumsService = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension BrowseDrumsViewModel {
    
    func downloadData() {
        if self.canDownloadMore() && !self.isDownloading.value {
            self.isDownloading.accept(true)
            self.fetchAllDrums()
        }
    }
    
    private func fetchAllDrums() {
        self.drumsService.fetchAllDrums(author: self.author, pagination: self.pageModel)
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
    
    private func update(_ data: [DrumModel]) {
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
        
        if self.containPostItem {
            items.append(PostDrumsCellViewModel())
        }
        items.append(contentsOf: self.drums.value.map { DrumsPostCellViewModel($0).then {
            self.setUpDrumPostCellObservers($0)
        }})
        
        if self.canDownloadMore() {
            let count: Int = !self.drums.value.isEmpty ? 0 : Int.random(in: (3..<6))
            items.append(contentsOf: (0...count).map { _ in DrumsPostCellViewModel(true) })
        } else {
            items.append(NoMorePostCellViewModel("You reach the end"))
        }
        
        return [.init(items: items)]
    }
    
    func authorDrumTitle() -> String? {
        if self.author == AuthData.shared.loggedDrumAuthor {
            return "My Drums"
        }
        return self.author
    }
}

// MARK: - Action Handlers
extension BrowseDrumsViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let _ = self.item(at: indexPath) as? PostDrumsCellViewModel {
            self.shouldPresent(AuthData.shared.isUserLoggedIn ? .postDrumViewController : .signInViewController)
        }
        
        if let item = self.item(at: indexPath) as? DrumsPostCellViewModel, let drum = item.post.value {
            let viewModel = DrumDetailViewModel(drum)
            self.shouldPresent(.drumDetailViewController(viewModel))
        }
    }
    
    func handleOnProfilePressed(_ author: String) {
        if author != self.author {
            self.shouldPresent(.authorDrumListingViewController(.init(author: author, containPostItem: false)))
        }
    }
    
    func handleQuotedDrumPressed(_ drum: DrumModel) {
        if let author = drum.postAuthor {
            let viewModel = DrumDetailViewModel(author: author, permlink: drum.postPermlink ?? "")
            self.shouldPresent(.drumDetailViewController(viewModel))
        }
    }
    
    func handleDrumActionPressed(_ drum: DrumModel, action: DrumsPostCellViewModel.DrumAction) {
        if !AuthData.shared.isUserLoggedIn {
            self.shouldPresent(.signInViewController)
            return
        }
        
        switch action {
        case .redrum:
            break
        case .comment:
            break
        case .vote:
            break
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
    
    func setUpDrumPostCellObservers(_ cellModel: DrumsPostCellViewModel) {
        cellModel.didProfilePressed.asObservable()
            .subscribe(onNext: { [weak self] author in
                self?.handleOnProfilePressed(author)
            }) ~ cellModel.disposeBag
        
        cellModel.didQuotedPostPressed.asObservable()
            .subscribe(onNext: { [weak self] drum in
                self?.handleQuotedDrumPressed(drum)
            }) ~ cellModel.disposeBag
        
        cellModel.didPostActionPressed.asObservable()
            .subscribe(onNext: { [weak self] action, drum in
                self?.handleDrumActionPressed(drum, action: action)
            }) ~ cellModel.disposeBag
    }
}
