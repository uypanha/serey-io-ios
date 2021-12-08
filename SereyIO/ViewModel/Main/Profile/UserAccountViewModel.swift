//
//  UserAccountViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/25/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

protocol ShouldRefreshProtocol {
    
    func shouldRefreshData()
}

class UserAccountViewModel: BaseViewModel, DownloadStateNetworkProtocol, ShouldPresent, ShouldReactToAction {
    
    enum Action {
        case changeProfilePressed
        case refresh
        case followPressed
        case photoSelected(PickerPhotoModel)
    }
    
    enum ViewToPresent {
        case postDetailViewController(PostDetailViewModel)
        case editPostController(CreatePostViewModel)
        case loading(Bool)
        case followLoading(Bool)
        case signInController
        case postsByCategoryController(PostTableViewModel)
        case voteDialogController(VoteDialogViewModel)
        case downVoteDialogController(DownvoteDialogViewModel)
        case signInViewController
        case draftListViewController(DraftListViewModel)
        case choosePhotoController
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let username: BehaviorRelay<String>
    let userInfo: BehaviorRelay<UserModel?>
    let profileImage: BehaviorRelay<UserProfileModel?>
    let followers: BehaviorRelay<[String]>
    let tabTitles: BehaviorRelay<[String]>
    let tabViewModels: BehaviorRelay<[BaseViewModel]>
    
    let profileViewModel: BehaviorSubject<ProfileViewModel?>
    let accountName: BehaviorSubject<String?>
    let postCountText: BehaviorSubject<String?>
    let followerCountText: BehaviorSubject<String?>
    let followingCountText: BehaviorSubject<String?>
    let isFollowHidden: BehaviorSubject<Bool>
    let isFollowed: BehaviorSubject<Bool?>
    let isUploadProfileHidden: BehaviorSubject<Bool>
    let endRefresh: BehaviorSubject<Bool>
    
    let userService: UserService
    let fileUploadService: FileUploadService
    let userProfileService: UserProfileService
    let isDownloading: BehaviorRelay<Bool>
    var didScrolledToIndex: Bool = false
    
    init(_ username: String) {
        self.username = .init(value: username)
        self.userInfo = .init(value: nil)
        self.profileImage = .init(value: nil)
        self.followers = .init(value: [])
        self.tabTitles = .init(value: [])
        self.tabViewModels = .init(value: [])
        
        self.profileViewModel = .init(value: nil)
        self.accountName = .init(value: nil)
        self.postCountText = .init(value: nil)
        self.followerCountText = .init(value: nil)
        self.followingCountText = .init(value: nil)
        self.isFollowHidden = .init(value: AuthData.shared.username == username)
        self.isFollowed = .init(value: nil)
        self.endRefresh = .init(value: false)
        self.userService = .init()
        self.fileUploadService = .init()
        self.userProfileService = .init()
        
        self.isDownloading = .init(value: false)
        self.isUploadProfileHidden = .init(value: AuthData.shared.username != username)
        super.init()
        
        let predicate = NSPredicate(format: "active == true AND username == %@", username)
        let defaultImage: UserProfileModel? = UserProfileModel().qeuryFirst(by: predicate)
        self.profileImage.accept(defaultImage)
        
        setUpRxObservers()
        prepareTabViewModels()
        registerForNotifs()
    }
    
    convenience init(_ user: UserModel) {
        self.init(user.name)
        
        self.userInfo.accept(user)
    }
    
    deinit {
        unregisterFromNotifs()
    }
}

// MARK: - Networks
extension UserAccountViewModel {
    
    func downloadData() {
        if !self.isDownloading.value {
            getProfile()
            getAllUserProfilePicture()
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
    
    func getAllUserProfilePicture() {
        self.userProfileService.getAllProfilePicture(self.username.value)
            .subscribe(onNext: { [weak self] profiles in
                profiles.saveAll()
                self?.profileImage.accept(profiles.first(where: { $0.active }))
            }) ~ self.disposeBag
    }
    
    func followAction(_ action: FollowActionType) {
        self.shouldPresent(.followLoading(true))
        self.isFollowHidden.onNext(true)
        self.userService.followAction(username.value, action: action)
            .subscribe(onNext: { [unowned self] response in
                self.shouldPresent(.followLoading(false))
                self.isFollowHidden.onNext(false)
                if response.action == "follow" {
                    self.followers.append(AuthData.shared.username!)
                } else {
                    if let indexToRemove = self.followers.value.index(where: { $0 == AuthData.shared.username }) {
                        self.followers.remove(at: indexToRemove)
                    }
                }
                }, onError: { [weak self] error in
                    self?.isFollowHidden.onNext(false)
                    self?.shouldPresent(.followLoading(false))
                    let errorInfo = ErrorHelper.prepareError(error: error)
                    self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    func uploadPhoto(_ pickerModel: PickerPhotoModel) {
        self.shouldPresent(.loading(true))
        self.fileUploadService.uploadPhoto(pickerModel.image)
            .subscribe(onNext: { [weak self] fileUpload in
                self?.addProfile(fileUpload.url)
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    func addProfile(_ url: String) {
        self.userProfileService.addUserProfile(url)
            .subscribe(onNext: { [weak self] data in
                self?.changeProfile(data.id)
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    func changeProfile(_ id: String) {
        self.userProfileService.changeProfile(id)
            .subscribe(onNext: { [weak self] data in
                self?.shouldPresent(.loading(false))
                self?.profileImage.accept(data)
                self?.getAllUserProfilePicture()
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
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
                return UserPostListViewModel(username)
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
        self.profileViewModel.onNext(prepareProfileViewModel(from: self.username.value))
        self.accountName.onNext((data?.name ?? self.username.value))
        self.postCountText.onNext(preparePostCountText(data?.postCount ?? 0))
        self.followerCountText.onNext(prepareFollowersCountText(data?.followersCount ?? 0))
        self.followingCountText.onNext(prepareFollowingsCountText(data?.followingCount ?? 0))
    }
    
    private func prepareProfileViewModel(from username: String) -> ProfileViewModel {
        let firstLetter = username.first == nil ? "" : "\(username.first!)"
        let uniqueColor = UIColor(hexString: PFColorHash().hex(username))
        return ProfileViewModel(shortcut: firstLetter, imageUrl: URL(string: self.profileImage.value?.imageUrl ?? ""), uniqueColor: uniqueColor)
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
        } else {
            self.shouldPresent(.signInController)
        }
    }
    
    func handleChangeProfilePressed() {
        self.shouldPresent(.choosePhotoController)
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
        
        self.profileImage.asObservable()
            .map { _ in self.userInfo.value }
            .subscribe(onNext: { [weak self] user in
                self?.notifyDataChanged(user)
            }) ~ self.disposeBag
        
        self.followers.asObservable()
            .filter { _ in AuthData.shared.username != self.username.value }
            .map { AuthData.shared.isUserLoggedIn ? $0.contains { $0 == AuthData.shared.username } : nil }
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
                case .postsByCategoryController(let postTableViewModel):
                    self?.shouldPresent(.postsByCategoryController(postTableViewModel))
                case .voteDialogController(let voteDialogViewModel):
                    self?.shouldPresent(.voteDialogController(voteDialogViewModel))
                case .downVoteDialogController(let downVoteDialogViewModel):
                    self?.shouldPresent(.downVoteDialogController(downVoteDialogViewModel))
                case .signInViewController:
                    self?.shouldPresent(.signInViewController)
                case .draftsViewController(let draftListViewModel):
                    self?.shouldPresent(.draftListViewController(draftListViewModel))
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
                case .changeProfilePressed:
                    self?.handleChangeProfilePressed()
                case .photoSelected(let pickerModel):
                    self?.uploadPhoto(pickerModel)
                }
            }) ~ self.disposeBag
    }
}

// MARK: - NotificationObserver
extension UserAccountViewModel: NotificationObserver {
    
    func notificationReceived(_ notification: Notification) {
        guard let appNotif = notification.appNotification else { return }
        switch appNotif {
        case .userDidLogin, .userDidLogOut:
            self.followers.renotify()
        default:
            break
        }
    }
}
