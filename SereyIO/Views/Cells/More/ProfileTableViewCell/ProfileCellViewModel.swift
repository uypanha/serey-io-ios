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
    
    init(_ user: UserModel?) {
        self.userInfo = BehaviorRelay(value: user)
        self.profileViewModel = BehaviorSubject(value: nil)
        self.authorName = BehaviorSubject(value: nil)
        super.init()
        
        setUpRxObservers()
    }
    
    private func notifyDataChanged(_ data: UserModel?) {
        self.profileViewModel.onNext(data?.profileModel)
        self.authorName.onNext(data?.name)
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
