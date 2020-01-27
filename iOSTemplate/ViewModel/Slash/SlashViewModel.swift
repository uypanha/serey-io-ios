//
//  SlashViewModel.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SlashViewModel: BaseViewModel, ShouldPresent {
    
    enum ViewToPresent {
        case loginViewController
        case homeViewController
    }
    
    // output:
    lazy var shouldPresent: Observable<ViewToPresent> = { [unowned self] in
        return self.shouldPresentSubject.asObservable()
    }()
    internal lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    func checkUserAuth() {
//        if AuthData.shared.isUserLoggedIn {
            self.shouldPresentSubject.onNext(.homeViewController)
//        } else {
//            self.shouldPresentSubject.onNext(.loginViewController)
//        }
    }
}
