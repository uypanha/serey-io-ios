//
//  AccountViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/14/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class AccountViewModel: BasePostViewModel, ShouldPresent, ShouldReactToAction {
    
    enum Action {
        case itemSelected(IndexPath)
        case followPressed
        case refresh
    }
    
    enum ViewToPresent {
        case postDetailViewController(PostDetailViewModel)
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<AccountViewModel.Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let username: BehaviorRelay<String>
    let userInfo: BehaviorRelay<UserModel?>
    let followers: BehaviorRelay<[String]>
    
    let profileViewModel: BehaviorSubject<ProfileViewModel?>
    let accountName: BehaviorSubject<String?>
    let postCountText: BehaviorSubject<String?>
    let followerCountText: BehaviorSubject<String?>
    let followingCountText: BehaviorSubject<String?>
    let isFollowHidden: BehaviorSubject<Bool>
    let isFollowed: BehaviorSubject<Bool>
    
    let userService: UserService
    
    init(_ username: String) {
        self.username = BehaviorRelay(value: username)
        self.userInfo = BehaviorRelay(value: nil)
        self.followers = BehaviorRelay(value: [])
        
        self.profileViewModel = BehaviorSubject(value: nil)
        self.accountName = BehaviorSubject(value: nil)
        self.postCountText = BehaviorSubject(value: nil)
        self.followerCountText = BehaviorSubject(value: nil)
        self.followingCountText = BehaviorSubject(value: nil)
        self.isFollowHidden = BehaviorSubject(value: AuthData.shared.username == username)
        self.isFollowed = BehaviorSubject(value: false)
        self.userService = UserService()
        super.init(.byUser(username))
        
        setUpRxObservers()
    }
    
    convenience init(_ user: UserModel) {
        self.init(user.name)
        
        self.userInfo.accept(user)
    }
    
    override func prepareEmptyViewModel() -> EmptyOrErrorViewModel {
        let title = R.string.post.noPostYet.localized()
        let emptyMessage = R.string.post.noPostMessage.localized()
        return EmptyOrErrorViewModel(withErrorEmptyModel: EmptyOrErrorModel(withEmptyTitle: title, emptyDescription: emptyMessage, iconImage: R.image.emptyPost()))
    }
}

// MARK: - Networks
extension AccountViewModel {
    
    func initialDownloadData() {
        downloadData()
        getFollowerList()
    }
    
    func getFollowerList() {
        self.userService.getFollowerList(self.username.value)
            .subscribe(onNext: { [weak self] response in
                self?.followers.accept(response.followerList)
            }, onError: { [weak self] error in
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
extension AccountViewModel {
    
    private func notifyDataChanged(_ data: UserModel?) {
        self.profileViewModel.onNext(data?.profileModel ?? prepareProfileViewModel(from: self.username.value))
        self.accountName.onNext(data?.name ?? self.username.value)
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
fileprivate extension AccountViewModel {
    
    func handleItemPressed(_ indexPath: IndexPath) {
        if let item = self.item(at: indexPath) as? PostCellViewModel {
            if let discussion = item.post.value {
                let viewModel = PostDetailViewModel(discussion)
                self.shouldPresent(.postDetailViewController(viewModel))
            }
        }
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
fileprivate extension AccountViewModel {
    
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
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indexPath):
                    self?.handleItemPressed(indexPath)
                case .refresh:
                    self?.reset()
                    self?.discussions.renotify()
                case .followPressed:
                    self?.handleFollowPressed()
                }
            }) ~ self.disposeBag
    }
}
