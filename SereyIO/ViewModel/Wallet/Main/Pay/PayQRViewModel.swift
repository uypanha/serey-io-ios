//
//  PayQRViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/9/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class PayQRViewModel: BaseViewModel, ShouldPresent, ShouldReactToAction {
    
    enum Action {
        case qrFound(String)
        case viewMyQRPressed
    }
    
    enum ViewToPresent {
        case receiveQRCodeController(ReceiveCoinViewModel)
        case dismiss
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let didUsernameFound: PublishSubject<String>
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        self.didUsernameFound = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - SetUp RxObservers
extension PayQRViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .qrFound(let username):
                    self?.shouldPresent(.dismiss)
                    self?.didUsernameFound.onNext(username)
                case .viewMyQRPressed:
                    let receiveCoinViewModel = ReceiveCoinViewModel(AuthData.shared.username ?? "")
                    self?.shouldPresent(.receiveQRCodeController(receiveCoinViewModel))
                }
            }) ~ self.disposeBag
    }
}
