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
import CountryPicker

class HomeViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent, DownloadStateNetworkProtocol {
    
    enum Action {
        case filterPressed
        case createPostPressed
        case countryPressed
        case countrySelected(CountryModel?)
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
        case bottomListViewController(BottomListMenuViewModel)
        case reportPostViewController(ReportPostViewModel)
        case confirmViewController(ConfirmDialogViewModel)
        case shareLink(URL, String)
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
    let userService: UserService
    var currentCountry: BehaviorRelay<CountryModel?>
    var didScrolledToIndex: Bool = false
    lazy var isDownloading = BehaviorRelay<Bool>(value: false)
    
    override init() {
        self.selectedCategory = .init(value: nil)
        self.postTabTitles = .init(value: [])
        self.postViewModels = .init(value: [])
        self.categories = .init(value: [])
        self.discussionService = .init()
        self.userService = .init()
        self.currentCountry = .init(value: PreferenceStore.shared.currentCountry)
        super.init()
        
        setUpRxObservers()
        let discussionTypes: [DiscussionType] = [.trending, .hot, .new]
        self.postTabTitles.accept(discussionTypes.map { $0.title })
        self.postViewModels.accept(discussionTypes.map { $0.prepareViewModel(self.selectedCategory) })
    }
    
    func validateCountry() {
        if self.currentCountry.value?.countryName != PreferenceStore.shared.currentUserCountry {
            self.currentCountry.accept(PreferenceStore.shared.currentCountry)
            self.selectedCategory.accept(nil)
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
    
    func fetchIpTrace() {
        self.userService.fetchIpTrace()
            .subscribe(onNext: { [weak self] data in
                if let loc = data?.split(separator: "\n").first(where: { $0.contains("loc=") }) {
                    let countryCode = loc.replacingOccurrences(of: "loc=", with: "")
                    if let country = CountryManager.shared.country(withCode: countryCode) {
                        self?.didAction(with: .countrySelected(.init(countryName: country.countryName, iconUrl: nil)))
                    }
                }
            }, onError: { [weak self] error in
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
        let viewModel = ChooseCategorySheetViewModel(categories: self.categories.value, self.selectedCategory)
        self.shouldPresent(.choosePostCategoryController(viewModel))
    }
    
    func handleCreatePost() {
        if AuthData.shared.isUserLoggedIn {
            self.shouldPresent(.createPostViewController)
        } else {
            self.shouldPresent(.signInViewController)
        }
    }
    
    func handleCountryPressed() {
        var items: [ImageTextCellViewModel] = [ChooseCountryOption.detectAutomatically, ChooseCountryOption.global].map { $0.cellModel }
        let countries: Results<CountryModel> = CountryModel().queryAll()
        items.append(contentsOf: countries.toArray().map { CountryCellViewModel($0) })
        
        let bottomListMenuViewModel = BottomListMenuViewModel(header: "Select your preffered country", items)
        bottomListMenuViewModel.shouldSelectMenuItem
            .subscribe(onNext: { [unowned self] cellModel in
                if let cellModel = cellModel as? ChooseCountryOptionCellViewModel {
                    switch cellModel.option {
                    case .detectAutomatically:
                        self.fetchIpTrace()
                    case .global:
                        self.didAction(with: .countrySelected(nil))
                    default:
                        break
                    }
                } else if let cellModel = cellModel as? CountryCellViewModel {
                    self.didAction(with: .countrySelected(cellModel.country))
                }
            }) ~ self.disposeBag
        
        self.shouldPresent(.bottomListViewController(bottomListMenuViewModel))
    }
}

// MARK: - SetUp RxObservers
extension HomeViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
//        self.selectedCategory.asObservable()
//            .skip(1)
//            .subscribe(onNext: { [weak self] selectedCategory in
//                self?.postViewModels.value.forEach({ postTableViewModel in
//                    postTableViewModel.setCategory(selectedCategory)
//                })
//            }) ~ self.disposeBag
        
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
                case .countrySelected(let country):
                    PreferenceStore.shared.currentUserCountry = country?.countryName
                    PreferenceStore.shared.currentUserCountryIconUrl = country?.iconUrl
                    self?.validateCountry()
                case .countryPressed:
                    self?.handleCountryPressed()
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
                case .reportPostController(let viewModel):
                    self?.shouldPresent(.reportPostViewController(viewModel))
                case .confirmViewController(let viewModel):
                    self?.shouldPresent(.confirmViewController(viewModel))
                case .shareLink(let url, let content):
                    self?.shouldPresent(.shareLink(url, content))
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
    
    func prepareViewModel(_ selectedCategory: BehaviorRelay<DiscussionCategoryModel?>) -> PostTableViewModel {
        return .init(self, selectedCategory)
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

