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
import RealmSwift
import Realm
import RxRealm

class HomeViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent, DownloadStateNetworkProtocol {
    
    enum Action {
        case filterPressed
        case createPostPressed
    }
    
    enum ViewToPresent {
        case choosePostCategoryController(ChooseCategorySheetViewModel)
        case postDetailViewController(PostDetailViewModel)
        case createPostViewController
        case signInViewController
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let selectedCategory: BehaviorRelay<DiscussionCategoryModel?>
    let postTabTitles: BehaviorRelay<[String]>
    let postViewModels: BehaviorRelay<[PostTableViewModel]>
    
    let categories: BehaviorRelay<[DiscussionCategoryModel]>
    
    let discussionService: DiscussionService
    lazy var isDownloading = BehaviorRelay<Bool>(value: false)
    
    override init() {
        self.selectedCategory = BehaviorRelay(value: nil)
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
                self?.updateData(categories)
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension HomeViewModel {
    
    fileprivate func updateData(_ categories: [DiscussionCategoryModel]) {
        self.categories.accept(categories)
    }
}

// MARK: - Action Handlers
fileprivate extension HomeViewModel {
    
    func handleFilterPressed() {
        let viewModel = ChooseCategorySheetViewModel(self.categories.value, self.selectedCategory.value)
        viewModel.categoryDidSelected.asObservable()
            .subscribe(onNext: { [weak self] selectedCategory in
                if selectedCategory?.name != self?.selectedCategory.value?.name {
                    self?.selectedCategory.accept(selectedCategory)
                }
            }) ~ viewModel.disposeBag
        self.shouldPresent(.choosePostCategoryController(viewModel))
    }
    
    func handleCreatePost() {
        if AuthData.shared.isUserLoggedIn {
            self.shouldPresent(.createPostViewController)
        } else {
            self.shouldPresent(.signInViewController)
        }
    }
}

// MARK: - SetUp RxObservers
extension HomeViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.selectedCategory.asObservable()
            .skip(1)
            .subscribe(onNext: { [weak self] selectedCategory in
                self?.postViewModels.value.forEach({ postTableViewModel in
                    postTableViewModel.setCategory(selectedCategory)
                })
            }) ~ self.disposeBag
        
        self.postViewModels.asObservable()
            .subscribe(onNext: { [unowned self] viewModels in
                viewModels.forEach { viewModel in
                    self.setUpPostTableViewModelObsevers(viewModel)
                }
            }) ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .filterPressed:
                    self?.handleFilterPressed()
                case .createPostPressed:
                    self?.handleCreatePost()
                }
            }) ~ self.disposeBag
    }
    
    func setUpPostTableViewModelObsevers(_ viewModel: PostTableViewModel) {
        viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .postDetailViewController(let postDetailViewModel):
                    self?.shouldPresent(.postDetailViewController(postDetailViewModel))
                }
            }) ~ viewModel.disposeBag
    }
}

// MARK: - PostTabType
enum DiscussionType {
    case trending
    case hot
    case new
    case byUser(String)
    
    var title: String {
        switch self {
        case .trending:
            return R.string.post.trending.localized()
        case .hot:
            return R.string.post.hot.localized()
        case .new:
            return R.string.post.new.localized()
        case .byUser:
            return "User"
        }
    }
    
    var authorParamName: String {
        switch self {
        case .byUser:
            return "userId"
        default:
            return "authorName"
        }
    }
    
    var authorName: String? {
        switch self {
        case .byUser(let username):
            return username
        default:
            return nil
        }
    }
    
    var viewModel: PostTableViewModel {
        return PostTableViewModel(self)
    }
    
    var emptyMessage: String {
        switch self {
        case .trending:
            return R.string.post.noTrendingPostMessage.localized()
        case .hot:
            return R.string.post.noHotPostMessage.localized()
        case .new:
            return R.string.post.noNewPostMessage.localized()
        case .byUser(let username):
            return username == AuthData.shared.username ? R.string.post.noPostMessage.localized() : String(format: R.string.post.noPostUserMessage.localized(), username, username)
        }
    }
}

