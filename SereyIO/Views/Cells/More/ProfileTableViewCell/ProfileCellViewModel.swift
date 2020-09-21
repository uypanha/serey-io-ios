//
//  ProfileCellViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/11/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class ProfileCellViewModel: CellViewModel {
    
    let userInfo: BehaviorRelay<UserModel?>
    let profileViewModel: BehaviorSubject<ProfileViewModel?>
    let authorName: BehaviorSubject<String?>
    let showSeperatorLine: BehaviorSubject<Bool>
    
    init(_ user: UserModel?, _ border: Bool = false) {
        self.userInfo = BehaviorRelay(value: user)
        self.profileViewModel = BehaviorSubject(value: nil)
        self.authorName = BehaviorSubject(value: nil)
        self.showSeperatorLine = BehaviorSubject(value: border)
        super.init()
        
        setUpRxObservers()
    }
    
    private func notifyDataChanged(_ data: UserModel?) {
        let username = AuthData.shared.username ?? ""
        self.profileViewModel.onNext(data?.profileModel ?? prepareProfileViewModel(from: username))
        self.authorName.onNext(data?.name ?? username)
    }
    
    private func prepareProfileViewModel(from username: String) -> ProfileViewModel {
        let firstLetter = username.first == nil ? "" : "\(username.first!)"
        let uniqueColor = UIColor(hexString: PFColorHash().hex(username))
        return ProfileViewModel(shortcut: firstLetter, imageUrl: nil, uniqueColor: uniqueColor)
    }
}

// MARK: -
fileprivate extension ProfileCellViewModel {
    
    func setUpRxObservers() {
        setUpContentObservers()
    }
    
    func setUpContentObservers() {
        self.userInfo.asObservable()
            .subscribe(onNext: { [weak self] data in
                self?.notifyDataChanged(data)
            }) ~ self.disposeBag
    }
}
