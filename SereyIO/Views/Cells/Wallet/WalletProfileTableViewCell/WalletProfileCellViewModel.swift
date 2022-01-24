//
//  WalletProfileCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/12/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class WalletProfileCellViewModel: CellViewModel {
    
    let userInfo: BehaviorRelay<UserModel?>
    let profileModel: BehaviorSubject<ProfileViewModel?>
    
    let shouldChangeProfile: PublishSubject<Void>
    
    init() {
        self.userInfo = .init(value: AuthData.shared.loggedUserModel)
        self.profileModel = .init(value: nil)
        
        self.shouldChangeProfile = .init()
        super.init()
     
        setUpRxObservers()
        notifyDataChanged(self.userInfo.value)
    }
    
    func notifyDataChanged(_ userModel: UserModel?) {
        self.profileModel.onNext(userModel?.profileModel)
    }
}

// MARK: - SetUP RxObservres
extension WalletProfileCellViewModel {
    
    func setUpRxObservers() {
        self.userInfo.asObservable()
            .`do`(onNext: { [weak self] userModel in
                if let userModel = userModel {
                    self?.setUpUserInfoObservers(userModel)
                }
            }).subscribe(onNext: { [unowned self] userModel in
                self.notifyDataChanged(userModel)
            }) ~ self.disposeBag
    }
    
    private func setUpUserInfoObservers(_ userInfo: UserModel) {
        Observable.from(object: userInfo)
            .asObservable()
            .subscribe(onNext: { [unowned self] userModel in
                self.notifyDataChanged(userModel)
            })  ~ self.disposeBag
    }
}
