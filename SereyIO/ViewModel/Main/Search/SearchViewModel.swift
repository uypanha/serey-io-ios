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
        case loadingIndicator(Bool)
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let cells: BehaviorRelay<[SectionItem]>
//    let places: BehaviorRelay<[PlaceModel]>
    
    lazy var canDownloadMorePages = BehaviorRelay<Bool>(value: true)
    lazy var downloadDisposeBag: DisposeBag = DisposeBag()
    lazy var isDownloading = BehaviorRelay<Bool>(value: false)
    
    let searchTextFieldViewModel: TextFieldViewModel
    fileprivate var editingDisposable: Disposable?
    
//    let searchService: SearchService
    
    override init() {
        self.cells = BehaviorRelay(value: [])
//        self.places = BehaviorRelay(value: [])
        self.searchTextFieldViewModel = TextFieldViewModel.textFieldWith(title: "Search")
//        self.searchService = SearchService()
        super.init()
        
        setUpRxObservers()
    }
    
    func initialData() {
        self.cells.accept([])
//        self.places.accept([])
    }
}

// MARK: - Networks
extension SearchViewModel {
    
    func downloadData() {
//        self.downloadDisposeBag = DisposeBag()
//        self.places.accept([])
//        if let searchText = self.searchTextFieldViewModel.value, !searchText.isEmpty {
//            self.isDownloading.accept(true)
//            self.searchService.searchGlobal(searchText)
//                .subscribe(onNext: { [weak self] data in
//                    self?.isDownloading.accept(false)
//                    if let places = data?.places {
//                        self?.places.accept(places)
//                    }
//                }, onError: { [weak self] error in
//                    self?.isDownloading.accept(false)
//                    let errorInfo = ErrorHelper.prepareError(error: error)
//                    self?.shouldPresentError(errorInfo)
//                }).disposed(by: self.downloadDisposeBag)
//        }
    }
}

// MARK: - Preparations & Tools
extension SearchViewModel {
    
    fileprivate func prepareCells() -> [SectionItem] {
//        var sections: [SectionItem] = []
//        if !places.isEmpty {
//            let cells: [CellViewModel] = places.map { PlaceCellViewModel($0) }
//            sections.append(AnimatedSectionModel(model: Section(), items: cells))
//        }
        return []
    }
    
    fileprivate func prepareEmptyViewModel() -> EmptyOrErrorViewModel {
        let title: String
        let emptyMessage: String
        if let searchText = self.searchTextFieldViewModel.value, !searchText.isEmpty {
            title = "People not found"
            emptyMessage = "No people found for \(searchText) at this moment"//String(format: R.string.cooperator.placeNotFoundMessage.localized(), searchText)
        } else {
            title = "Searh People"
            emptyMessage = "Enter a name of people you want to search for"
        }
        return EmptyOrErrorViewModel(withErrorEmptyModel: EmptyOrErrorModel(withEmptyTitle: title, emptyDescription: emptyMessage, iconImage: R.image.searchPeople()))
    }
    
//    func prepareEmptyViewModel(_ erroInfo: ErrorInfo) -> EmptyOrErrorViewModel {
//        return EmptyOrErrorViewModel(withErrorEmptyModel: EmptyOrErrorModel(withErrorInfo: erroInfo, actionTitle: R.string.common.tryAgain.localized(), actionCompletion: {
//            self.downloadData()
//        }))
//    }
}

// MARK: - Action Handlers
fileprivate extension SearchViewModel {
    
    func handleItemSelected(_ at: IndexPath) {
//        if let placeItem = self.item(at: at) as? PlaceCellViewModel {
//            self.shouldPresent(.placeDetailController(PlaceDetailViewModel(placeItem.place.value)))
//        }
    }
    
    func handleEditingChanged() {
        self.editingDisposable?.dispose()
        self.editingDisposable = Observable<Int>.just(1)
            .delay(1, scheduler: MainScheduler.instance)
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
//        self.places.asObservable()
//            .map { self.prepareCells($0) }
//            .bind(to: self.cells)
//            .disposed(by: self.disposeBag)
//
        self.cells.asObservable()
            .subscribe(onNext: { [unowned self] cells in
                if cells.isEmpty {
                    self.shouldPresent(.emptyResult(self.prepareEmptyViewModel()))
                }
            }).disposed(by: self.disposeBag)
        
        self.isDownloading
            .asObservable()
            .skip(1)
            .subscribe(onNext: { [unowned self] downloading in
                self.shouldPresent(.loadingIndicator(downloading ? self.cells.value.isEmpty : downloading))
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

