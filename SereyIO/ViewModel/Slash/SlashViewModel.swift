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
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    override init() {
        self.shouldPresentSubject = .init()
        super.init()
    }
    
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
