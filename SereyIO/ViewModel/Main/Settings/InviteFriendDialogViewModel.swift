//
//  InviteFriendDialogViewModel.swift
//  SereyIO
//
//  Created by Panha on 5/4/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class InviteFriendDialogViewModel: BaseViewModel {
    
    let referralId: BehaviorRelay<String>
    let referralUrl: BehaviorRelay<String?>
    
    init(_ referralId: String) {
        self.referralId = .init(value: referralId)
        self.referralUrl = .init(value: nil)
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - SetUp RxObservers
private extension InviteFriendDialogViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.referralId.asObservable()
            .map { "\(Constants.kycURL.description)/?referralId=\($0)" }
            ~> self.referralUrl
            ~ self.disposeBag
    }
}
