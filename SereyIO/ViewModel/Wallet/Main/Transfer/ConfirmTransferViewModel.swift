//
//  ConfirmTransferViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/10/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class ConfirmTransferViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case transferPressed
    }
    
    enum ViewToPresent {
        case dismiss
    }

    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let fromUsername: BehaviorSubject<String?>
    let toUsername: BehaviorSubject<String?>
    let amount: BehaviorSubject<String?>
    
    let confirmed: PublishSubject<Void>
    
    init(from username: String, to: String, amount: String) {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.fromUsername = .init(value: username)
        self.toUsername = .init(value: to)
        self.amount = .init(value: amount)
        
        self.confirmed = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - SetUp RxObservers
extension ConfirmTransferViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .transferPressed:
                    self?.confirmed.onNext(())
                    self?.shouldPresent(.dismiss)
                }
            }) ~ self.disposeBag
    }
}
