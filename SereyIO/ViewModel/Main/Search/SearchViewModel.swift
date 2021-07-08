//
//  SearchViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/6/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

class SearchViewModel: BaseCellViewModel, CollectionMultiSectionsProviderModel, DownloadStateNetworkProtocol, ShouldPresent, ShouldReactToAction {
    
    enum Action {
        case itemSelected(at: IndexPath)
        case searchEditingChanged
    }
    
    enum ViewToPresent {
        case emptyResult(EmptyOrErrorViewModel)
        case accountViewController(UserAccountViewModel)
        case postDetailViewController(PostDetailViewModel)
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let cells: BehaviorRelay<[SectionItem]>
    let posts: BehaviorRelay<[PostModel]>
    
    lazy var canDownloadMorePages = BehaviorRelay<Bool>(value: true)
    lazy var downloadDisposeBag: DisposeBag = DisposeBag()
    lazy var isDownloading = BehaviorRelay<Bool>(value: false)
    
    let searchTextFieldViewModel: TextFieldViewModel
    fileprivate var editingDisposable: Disposable?
    
    let searchService: SearchService
    
    override init() {
        self.cells = BehaviorRelay(value: [])
        self.posts = BehaviorRelay(value: [])
        self.searchTextFieldViewModel = TextFieldViewModel.textFieldWith(title: R.string.search.search.localized())
        self.searchService = SearchService()
        super.init()
        
        setUpRxObservers()
    }
    
    func initialData() {
        self.posts.accept([])
    }
}

// MARK: - Networks
extension SearchViewModel {
    
    func downloadData() {
        self.downloadDisposeBag = DisposeBag()
        if let searchText = self.searchTextFieldViewModel.value, !searchText.isEmpty {
            self.isDownloading.accept(true)
            self.posts.accept([])
            self.searchService.search(.init(query: searchText))
                .subscribe(onNext: { [weak self] data in
                    self?.isDownloading.accept(false)
                    self?.posts.accept(data)
                }, onError: { [weak self] error in
                    self?.isDownloading.accept(false)
                    let errorInfo = ErrorHelper.prepareError(error: error)
                    self?.shouldPresentError(errorInfo)
                }).disposed(by: self.downloadDisposeBag)
        } else {
            self.posts.accept([])
        }
    }
}

// MARK: - Preparations & Tools
extension SearchViewModel {
    
    fileprivate func prepareCells(_ people: [PostModel]) -> [SectionItem] {
        var sections: [SectionItem] = []
        if !people.isEmpty {
            let cells: [CellViewModel] = people.map { PostCellViewModel($0) }
            sections.append(SectionModel(model: Section(), items: cells))
        } else if self.isDownloading.value {
            sections.append(SectionModel(items: (0...4).map { _ in PostCellViewModel(true) }))
        }
        return sections
    }
    
    fileprivate func prepareEmptyViewModel() -> EmptyOrErrorViewModel {
        let title: String
        let emptyMessage: String
        if let searchText = self.searchTextFieldViewModel.value, !searchText.isEmpty {
            title = R.string.search.peopleNotFound.localized()
            emptyMessage = String(format: R.string.search.peopleNotFoundMessage.localized(), searchText)
        } else {
            title = R.string.search.searchPeople.localized()
            emptyMessage = R.string.search.searchPeopleMessage.localized()
        }
        return EmptyOrErrorViewModel(withErrorEmptyModel: EmptyOrErrorModel(withEmptyTitle: title, emptyDescription: emptyMessage, iconImage: R.image.searchPeople()))
    }
    
    open func prepareEmptyViewModel(_ erroInfo: ErrorInfo) -> EmptyOrErrorViewModel {
        return EmptyOrErrorViewModel(withErrorEmptyModel: EmptyOrErrorModel(withErrorInfo: erroInfo, actionTitle: R.string.common.tryAgain.localized(), actionCompletion: { [unowned self] in
            self.downloadData()
        }))
    }
}

// MARK: - Action Handlers
fileprivate extension SearchViewModel {
    
    func handleItemSelected(_ at: IndexPath) {
        if let item = self.item(at: at) as? PeopleCellViewModel, let username = item.people.value {
            let accountViewModel = UserAccountViewModel(username)
            self.shouldPresent(.accountViewController(accountViewModel))
        }
        
        if let item = self.item(at: at) as? PostCellViewModel, let post = item.post.value {
            let postDetailViewModel = PostDetailViewModel(post)
            self.shouldPresent(.postDetailViewController(postDetailViewModel))
        }
    }
    
    func handleEditingChanged() {
        self.editingDisposable?.dispose()
        self.editingDisposable = Observable<Int>.just(1)
            .delay(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.downloadData()
            })
        self.editingDisposable?.disposed(by: self.disposeBag)
    }
}

// MARK: - SetUp RxObservers
fileprivate extension SearchViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.posts.asObservable()
            .map { self.prepareCells($0) }
            .bind(to: self.cells)
            .disposed(by: self.disposeBag)

        self.cells.asObservable()
            .subscribe(onNext: { [unowned self] cells in
                if cells.isEmpty {
                    self.shouldPresent(.emptyResult(self.prepareEmptyViewModel()))
                }
            }).disposed(by: self.disposeBag)
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indexPath):
                    self?.handleItemSelected(indexPath)
                case .searchEditingChanged:
                    self?.handleEditingChanged()
                }
            }).disposed(by: self.disposeBag)
    }
}
