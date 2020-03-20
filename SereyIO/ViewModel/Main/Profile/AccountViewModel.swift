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

class AccountViewModel: BasePostViewModel, ShouldPresent {
    
    enum ViewToPresent {
        case postDetailViewController
    }
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let username: BehaviorRelay<String>
    let userInfo: BehaviorRelay<UserModel?>
    let profileViewModel: BehaviorSubject<ProfileViewModel?>
    let accountName: BehaviorSubject<String?>
    let postCountText: BehaviorSubject<String?>
    let followerCountText: BehaviorSubject<String?>
    let followingCountText: BehaviorSubject<String?>
    let isFollowHidden: BehaviorSubject<Bool>
    let isFollowed: BehaviorSubject<Bool>
    
    init(_ username: String) {
        self.username = BehaviorRelay(value: username)
        self.userInfo = BehaviorRelay(value: nil)
        self.profileViewModel = BehaviorSubject(value: nil)
        self.accountName = BehaviorSubject(value: nil)
        self.postCountText = BehaviorSubject(value: nil)
        self.followerCountText = BehaviorSubject(value: nil)
        self.followingCountText = BehaviorSubject(value: nil)
        self.isFollowHidden = BehaviorSubject(value: AuthData.shared.username == username)
        self.isFollowed = BehaviorSubject(value: false)
        super.init(.byUser, username)
        
        setUpRxObservers()
    }
    
    convenience init(_ user: UserModel) {
        self.init(user.name)
        
        self.userInfo.accept(user)
    }
    
    override func prepareEmptyViewModel() -> EmptyOrErrorViewModel {
        let title = "No Post Yet!"
        let emptyMessage = "Your post will be shown here after you\nmade a post."
        return EmptyOrErrorViewModel(withErrorEmptyModel: EmptyOrErrorModel(withEmptyTitle: title, emptyDescription: emptyMessage, iconImage: R.image.emptyPost()))
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
        return "\(count) Following\(preparePluralNumberSuffix(count))"
    }
    
    private func prepareFollowersCountText(_ count: Int) -> String {
        return "\(count) Follower\(preparePluralNumberSuffix(count))"
    }
    
    private func preparePostCountText(_ count: Int) -> String {
        return "\(count) Post\(preparePluralNumberSuffix(count))"
    }
    
    private func preparePluralNumberSuffix(_ count: Int) -> String {
        return count > 1 ? "s" : ""
    }
}

// MARK: - SetUp RxObservers
fileprivate extension AccountViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.userInfo.asObservable()
            .subscribe(onNext: { [weak self] user in
                self?.notifyDataChanged(user)
            }) ~ self.disposeBag
    }
}
