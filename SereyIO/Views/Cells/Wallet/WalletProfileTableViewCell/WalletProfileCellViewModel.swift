//
//  WalletProfileCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/12/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class WalletProfileCellViewModel: CellViewModel {
    
    let userInfo: BehaviorRelay<UserModel?>
    let profileModel: BehaviorSubject<ProfileViewModel?>
    
    init() {
        self.userInfo = .init(value: AuthData.shared.loggedUserModel)
        self.profileModel = .init(value: nil)
        super.init()
     
        notifyDataChanged(self.userInfo.value)
    }
    
    func notifyDataChanged(_ userModel: UserModel?) {
        self.profileModel.onNext(userModel?.profileModel)
    }
}
