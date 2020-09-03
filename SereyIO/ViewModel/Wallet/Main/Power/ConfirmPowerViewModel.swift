//
//  ConfirmPowerViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/30/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class ConfirmPowerViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {
    
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
    
    init(from username: String, _ type: PowerType) {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.fromAccount = .init(value: username)
        self.toAccount = .init(value: type.account)
        self.amount = .init(value: type.amount)
        
        self.confirmed = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - SetUp RxObservers
extension ConfirmPowerViewModel {
    
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

enum PowerType {
    case up(account: String, amount: String)
    case down(amount: String)
    
    var account: String? {
        switch self {
        case .up(let account, _):
            return account
        case .down:
            return nil
        }
    }
    
    var amount: String {
        switch self {
        case .up(_ , let amount):
            return amount
        case .down(let amount):
            return amount
        }
    }
    
//    var icon: UIImage? {
//        switch self {
//        case .up:
//            return WalletMenu.powerUp.image
//        case .down:
//            return WalletMenu.powerDown.image
//        }
//    }
//
//    var iconBackground: UIColor? {
//        switch self {
//        case .up:
//            return WalletMenu.powerUp.backgroundColor
//        case .down:
//            return WalletMenu.powerDown.backgroundColor
//        }
//    }
}
