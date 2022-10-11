//
//  SignInCellViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/12/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class SignInCellViewModel: CellViewModel, ShouldReactToAction {
    
    enum Action {
        case signInPressed
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<SignInCellViewModel.Action>()
    
    // output:
    lazy var shouldSignIn = PublishSubject<Void>()
    
    init() {
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - SetUP RxObservers
fileprivate extension SignInCellViewModel {
    
    func setUpRxObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] (action) in
                switch action {
                case .signInPressed:
                    self?.shouldSignIn.onNext(())
                }
            }).disposed(by: self.disposeBag)
    }
}
