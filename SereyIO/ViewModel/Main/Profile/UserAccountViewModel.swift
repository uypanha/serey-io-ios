//
//  UserAccountViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/25/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

protocol ShouldRefreshProtocol {
    
    func shouldRefreshData()
}

class UserAccountViewModel: BaseViewModel, DownloadStateNetworkProtocol, ShouldPresent, ShouldReactToAction {
    
    enum Action {
        case refresh
        case followPressed
    }
    
    enum ViewToPresent {
        case postDetailViewController(PostDetailViewModel)
        case editPostController(CreatePostViewModel)
        case loading(Bool)
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let username: BehaviorRelay<String>
    let userInfo: BehaviorRelay<UserModel?>
    let followers: BehaviorRelay<[String]>
    let tabTitles: BehaviorRelay<[String]>
    let tabViewModels: BehaviorRelay<[BaseViewModel]>
    
    let profileViewModel: BehaviorSubject<ProfileViewModel?>
    let accountName: BehaviorSubject<String?>
    let postCountText: BehaviorSubject<String?>
    let followerCountText: BehaviorSubject<String?>
    let followingCountText: BehaviorSubject<String?>
    let isFollowHidden: BehaviorSubject<Bool>
    let isFollowed: BehaviorSubject<Bool>
    let endRefresh: BehaviorSubject<Bool>
    
    let userService: UserService
    let isDownloading: BehaviorRelay<Bool>
    
    init(_ username: String) {
        self.username = BehaviorRelay(value: username)
        self.userInfo = BehaviorRelay(value: nil)
        self.followers = BehaviorRelay(value: [])
        self.tabTitles = BehaviorRelay(value: [])
        self.tabViewModels = BehaviorRelay(value: [])
        
        self.profileViewModel = BehaviorSubject(value: nil)
        self.accountName = BehaviorSubject(value: nil)
        self.postCountText = BehaviorSubject(value: nil)
        self.followerCountText = BehaviorSubject(value: nil)
        self.followingCountText = BehaviorSubject(value: nil)
        self.isFollowHidden = BehaviorSubject(value: AuthData.shared.username == username)
        self.isFollowed = BehaviorSubject(value: false)
        self.endRefresh = BehaviorSubject(value: false)
        self.userService = UserService()
        self.isDownloading = BehaviorRelay(value: false)
        super.init()
        
        setUpRxObservers()
        prepareTabViewModels()
    }
    
    convenience init(_ user: UserModel) {
        self.init(user.name)
        
        self.userInfo.accept(user)
    }
}

// MARK: - Networks
extension UserAccountViewModel {
    
    func downloadData() {
        if !self.isDownloading.value {
            getProfile()
        }
    }
    
    func getProfile() {
        self.isDownloading.accept(true)
        self.userService.fetchProfile(self.username.value)
            .flatMap { [unowned self] data -> Observable<FollowerListResponse> in
                self.userInfo.accept(data.data.result)
                return self.userService.getFollowerList(self.username.value)
            }
            .subscribe(onNext: { [weak self] data in
                self?.isDownloading.accept(false)
                self?.followers.accept(data.followerList)
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    func followAction(_ action: FollowActionType) {
        self.userService.followAction(username.value, action: action)
            .subscribe(onNext: { response in
                if response.action == "follow" {
                    self.followers.append(AuthData.shared.username!)
                } else {
                    if let indexToRemove = self.followers.value.index(where: { $0 == AuthData.shared.username }) {
                        self.followers.remove(at: indexToRemove)
                    }
                }
            }, onError: { [weak self] error in
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension UserAccountViewModel {
    
    enum TabItem: CaseIterable {
        case post
        case comment
        case replies
        
        var title: String {
            switch self {
            case .post:
                return R.string.post.post.localized()
            case .comment:
                return R.string.post.comments.localized()
            case .replies:
                return R.string.post.replies.localized()
            }
        }
        
        func prepareViewModel(_ username: String) -> BaseViewModel {
            switch self {
            case .post:
                return PostTableViewModel(.byUser(username))
            case .comment:
                return CommentsListViewModel(username, with: .comments)
            case .replies:
                return CommentsListViewModel(username, with: .replies)
            }
        }
    }
    
    func prepareTabViewModels() {
        self.tabViewModels.accept(TabItem.allCases.map { $0.prepareViewModel(self.username.value) })
        self.tabTitles.accept(TabItem.allCases.map { $0.title })
    }
    
    private func notifyDataChanged(_ data: UserModel?) {
        self.profileViewModel.onNext(data?.profileModel ?? prepareProfileViewModel(from: self.username.value))
        self.accountName.onNext((data?.name ?? self.username.value)?.capitalized)
        self.postCountText.onNext(preparePostCountText(data?.postCount ?? 0))
        self.followerCountText.onNext(prepareFollowersCountText(data?.followersCount ?? 0))
        self.followingCountText.onNext(prepareFollowingsCountText(data?.followingCount ?? 0))
    }
    
    private func prepareProfileViewModel(from username: String) -> ProfileViewModel {
        let firstLetter = username.first == nil ? "" : "\(username.first!)"
        let uniqueColor = UIColor(hexString: PFColorHash().hex(username))
        return ProfileViewModel(shortcut: firstLetter, imageUrl: nil, uniqueColor: uniqueColor)
    }
    
    private func prepareFollowingsCountText(_ count: Int) -> String {
        return String(format: R.string.account.followingCount.localized(), "\(count)", preparePluralNumberSuffix(count))
    }
    
    private func prepareFollowersCountText(_ count: Int) -> String {
        return String(format: R.string.account.followerCount.localized(), "\(count)", preparePluralNumberSuffix(count))
    }
    
    private func preparePostCountText(_ count: Int) -> String {
        return String(format: R.string.account.postCount.localized(), "\(count)", preparePluralNumberSuffix(count))
    }
    
    private func preparePluralNumberSuffix(_ count: Int) -> String {
        return count > 1 ? R.string.common.ploralSuffix.localized() : ""
    }
}

// MARK: - Action Handlers
fileprivate extension UserAccountViewModel {
    
    func handleRefress() {
        self.tabViewModels.value.forEach { viewModel in
            (viewModel as? ShouldRefreshProtocol)?.shouldRefreshData()
        }
        self.downloadData()
    }
    
    func handleFollowPressed() {
        if let loggedUsername = AuthData.shared.username {
            if followers.value.contains(where: { $0 == loggedUsername }) {
                self.followAction(.unfollow)
            } else {
                self.followAction(.follow)
            }
        }
    }
}

// MARK: - SetUp RxObservers
fileprivate extension UserAccountViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.userInfo.asObservable()
            .subscribe(onNext: { [weak self] user in
                self?.notifyDataChanged(user)
            }) ~ self.disposeBag
        
        self.followers.asObservable()
            .filter { _ in AuthData.shared.username != self.username.value }
            .map { $0.contains { $0 == AuthData.shared.username } }
            ~> self.isFollowed
            ~ self.disposeBag
        
        self.isDownloading.asObservable()
            .filter { !$0 }
            .map { !$0 }
            ~> self.endRefresh
            ~ self.disposeBag
        
        self.tabViewModels.asObservable()
            .subscribe(onNext: { [unowned self] viewModels in
                viewModels.forEach { viewModel in
                    self.setUpTabViewModelObsevers(viewModel)
                }
            }) ~ self.disposeBag
    }
    
    func setUpTabViewModelObsevers(_ viewModel: BaseViewModel) {
        switch viewModel {
        case is PostTableViewModel:
            self.setUpPostTableViewModelObsevers(viewModel as! PostTableViewModel)
        default:
            break
        }
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
                default:
                    break
                }
            }) ~ viewModel.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .refresh:
                    self?.handleRefress()
                case .followPressed:
                    self?.handleFollowPressed()
                }
            }) ~ self.disposeBag
    }
}
