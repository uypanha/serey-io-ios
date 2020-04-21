//
//  SlashViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SlashViewModel: BaseViewModel, ShouldPresent {
    
    enum ViewToPresent {
        case homeViewController
        case selectLanguageController
    }
    
    // output:
    lazy var shouldPresent: Observable<ViewToPresent> = { [unowned self] in
        return self.shouldPresentSubject.asObservable()
    }()
    internal lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    func determineInitialScreen() {
        if AuthData.shared.isUserLoggedIn, let expiry = AuthData.shared.expiration {
            let now = Date().timeIntervalSince1970
            if expiry <= now {
                AuthData.shared.removeAuthData()
            }
        }
        
        if FeatureStore.shared.areFeaturesIntroduced {
            self.shouldPresentSubject.onNext(.homeViewController)
        } else {
            self.shouldPresentSubject.onNext(.selectLanguageController)
        }
    }
}
