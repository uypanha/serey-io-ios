//
//  HomeViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/6/20.
//  Copyright © 2020 Serey IO. All rights reserved.
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
        case editPostController(CreatePostViewModel)
        case postDetailViewController(PostDetailViewModel)
        case createPostViewController
        case signInViewController
        case loading(Bool)
        case postsByCategoryController(PostTableViewModel)
        case userAccountController(UserAccountViewModel)
        case voteDialogController(VoteDialogViewModel)
        case downVoteDialogController(DownvoteDialogViewModel)
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
    var currentCountryCode: String?
    var didScrolledToIndex: Bool = false
    lazy var isDownloading = BehaviorRelay<Bool>(value: false)
    
    override init() {
        self.selectedCategory = BehaviorRelay(value: nil)
        self.postTabTitles = BehaviorRelay(value: [])
        self.postViewModels = BehaviorRelay(value: [])
        self.categories = BehaviorRelay(value: [])
        self.discussionService = DiscussionService()
        self.currentCountryCode = PreferenceStore.shared.currentUserCountryCode
        super.init()
        
        setUpRxObservers()
        let discussionTypes: [DiscussionType] = [.trending, .hot, .new]
        self.postTabTitles.accept(discussionTypes.map { $0.title })
        self.postViewModels.accept(discussionTypes.map { $0.viewModel })
    }
    
    func validateCountry() {
        if self.currentCountryCode != PreferenceStore.shared.currentUserCountryCode {
            self.currentCountryCode = PreferenceStore.shared.currentUserCountryCode
            self.downloadData()
            self.postViewModels.value.forEach { viewModel in
                viewModel.validateCountry()
            }
        }
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
                case .editPostController(let createPostViewModel):
                    self?.shouldPresent(.editPostController(createPostViewModel))
                case .loading(let loading):
                    self?.shouldPresent(.loading(loading))
                case .postsByCategoryController(let postTableViewModel):
                    self?.shouldPresent(.postsByCategoryController(postTableViewModel))
                case .userAccountController(let userAccountViewModel):
                    self?.shouldPresent(.userAccountController(userAccountViewModel))
                case .voteDialogController(let voteDialogViewModel):
                    self?.shouldPresent(.voteDialogController(voteDialogViewModel))
                case .downVoteDialogController(let downVoteDialogViewModel):
                    self?.shouldPresent(.downVoteDialogController(downVoteDialogViewModel))
                case .signInViewController:
                    self?.shouldPresent(.signInViewController)
                default:
                    break
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
    case byCategoryId(String)
    
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
        case .byCategoryId(let category):
            return String(format: R.string.post.postsByCategory.localized(), category.capitalized)
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
    
    var categoryParamName: String {
        switch self {
        case .byCategoryId:
            return "categoryId"
        default:
            return "categoryName"
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
    
    var categoryName: String? {
        switch self {
        case .byCategoryId(let categoryId):
            return categoryId
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
        case .byCategoryId(let category):
            return String(format: R.string.post.noPostByCategoryMessage.localized(), category)
        }
    }
}

