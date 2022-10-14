//
//  DelegatedUserCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 12/10/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class DelegatedUserCellViewModel: CellViewModel, ShimmeringProtocol {
    
    let delegateUser: BehaviorRelay<DelegatedUserModel?>
    let profileViewModel: BehaviorSubject<ProfileViewModel?>
    let profileName: BehaviorSubject<String?>
    let powerAmount: BehaviorSubject<String?>
    
    let isShimmering: BehaviorRelay<Bool>
    let shouldRemoveDelegate: PublishSubject<DelegatedUserModel>
    
    init(_ delegateUser: DelegatedUserModel?) {
        self.delegateUser = .init(value: delegateUser)
        self.profileViewModel = .init(value: delegateUser?.profileViewModel)
        self.profileName = .init(value: delegateUser?.userName)
        self.powerAmount = .init(value: delegateUser?.amount)
        self.isShimmering = .init(value: false)
        self.shouldRemoveDelegate = .init()
        super.init()
    }
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil)
        
        self.isShimmering.accept(isShimmering)
    }
}

// MARK: - Action Handlers
extension DelegatedUserCellViewModel {
    
    func handleRemoveDelegatePressed() {
        if let data = self.delegateUser.value {
            self.shouldRemoveDelegate.onNext(data)
        }
    }
}
