//
//  ConfirmDelegatePowerViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 11/8/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class ConfirmDelegatePowerViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case confirmPressed
    }
    
    enum ViewToPresent {
        case dismiss
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let fromAccount: BehaviorSubject<String?>
    let toAccount: BehaviorSubject<String?>
    let amount: BehaviorSubject<String?>
    
    let confirmed: PublishSubject<Void>
    
    init(from username: String, to account: String, amount: String) {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.fromAccount = .init(value: username)
        self.toAccount = .init(value: account)
        self.amount = .init(value: amount)
        
        self.confirmed = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - SetUp RxObservers
extension ConfirmDelegatePowerViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .confirmPressed:
                    self?.confirmed.onNext(())
                    self?.shouldPresent(.dismiss)
                }
            }) ~ self.disposeBag
    }
}
