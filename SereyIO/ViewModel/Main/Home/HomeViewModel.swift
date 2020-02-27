//
//  HomeViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class HomeViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent, DownloadStateNetworkProtocol {
    
    enum Action {
        case filterPressed
    }
    
    enum ViewToPresent {
        case choosePostCategoryController(ChooseCategorySheetViewModel)
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let postTabTitles: BehaviorRelay<[String]>
    let postViewModels: BehaviorRelay<[PostTableViewModel]>
    
    let categories: BehaviorRelay<[DiscussionCategoryModel]>
    
    let discussionService: DiscussionService
    lazy var isDownloading = BehaviorRelay<Bool>(value: false)
    
    override init() {
        self.postTabTitles = BehaviorRelay(value: [])
        self.postViewModels = BehaviorRelay(value: [])
        self.categories = BehaviorRelay(value: [])
        self.discussionService = DiscussionService()
        super.init()
        
        setUpRxObservers()
        let discussionTypes: [DiscussionType] = [.trending, .hot, .new]
        self.postTabTitles.accept(discussionTypes.map { $0.title })
        self.postViewModels.accept(discussionTypes.map { $0.viewModel })
    }
}

// MARK: - Networks
extension HomeViewModel {
    
    func downloadData() {
        if !self.isDownloading.value {
            fetchCategories()
        }
    }
    
    private func fetchCategories() {
        self.isDownloading.accept(true)
        self.discussionService.getCategories()
            .subscribe(onNext: { [weak self] categories in
                self?.isDownloading.accept(false)
                self?.categories.accept(categories)
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Action Handlers
fileprivate extension HomeViewModel {
    
    func handleFilterPressed() {
        let viewModel = ChooseCategorySheetViewModel(self.categories.value)
        self.shouldPresent(.choosePostCategoryController(viewModel))
    }
}

// MARK: - SetUp RxObservers
extension HomeViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .filterPressed:
                    self?.handleFilterPressed()
                }
            }) ~ self.disposeBag
    }
}

// MARK: - PostTabType
enum DiscussionType {
    case trending
    case hot
    case new
    case byUser
    
    var title: String {
        switch self {
        case .trending:
            return "Trending"
        case .hot:
            return "Hot"
        case .new:
            return "New"
        case .byUser:
            return "User"
        }
    }
    
    var viewModel: PostTableViewModel {
        return PostTableViewModel(self)
    }
}

