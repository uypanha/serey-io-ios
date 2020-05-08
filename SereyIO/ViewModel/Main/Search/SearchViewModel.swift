//
//  SearchViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
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
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let cells: BehaviorRelay<[SectionItem]>
    let people: BehaviorRelay<[PeopleModel]>
    
    lazy var canDownloadMorePages = BehaviorRelay<Bool>(value: true)
    lazy var downloadDisposeBag: DisposeBag = DisposeBag()
    lazy var isDownloading = BehaviorRelay<Bool>(value: false)
    
    let searchTextFieldViewModel: TextFieldViewModel
    fileprivate var editingDisposable: Disposable?
    
    let searchService: SearchService
    
    override init() {
        self.cells = BehaviorRelay(value: [])
        self.people = BehaviorRelay(value: [])
        self.searchTextFieldViewModel = TextFieldViewModel.textFieldWith(title: R.string.search.search.localized())
        self.searchService = SearchService()
        super.init()
        
        setUpRxObservers()
    }
    
    func initialData() {
        self.people.accept([])
    }
}

// MARK: - Networks
extension SearchViewModel {
    
    func downloadData() {
        self.downloadDisposeBag = DisposeBag()
        if let searchText = self.searchTextFieldViewModel.value, !searchText.isEmpty {
            self.isDownloading.accept(true)
            self.people.accept([])
            self.searchService.search(searchText)
                .subscribe(onNext: { [weak self] data in
                    self?.isDownloading.accept(false)
                    self?.people.accept(data)
                }, onError: { [weak self] error in
                    self?.isDownloading.accept(false)
                    let errorInfo = ErrorHelper.prepareError(error: error)
                    self?.shouldPresentError(errorInfo)
                }).disposed(by: self.downloadDisposeBag)
        } else {
            self.people.accept([])
        }
    }
}

// MARK: - Preparations & Tools
extension SearchViewModel {
    
    fileprivate func prepareCells(_ people: [PeopleModel]) -> [SectionItem] {
        var sections: [SectionItem] = []
        if !people.isEmpty {
            let cells: [CellViewModel] = people.map { PeopleCellViewModel($0) }
            sections.append(SectionModel(model: Section(), items: cells))
        } else if self.isDownloading.value {
            sections.append(SectionModel(items: (0...11).map { _ in PeopleCellViewModel(true) }))
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
        self.people.asObservable()
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
