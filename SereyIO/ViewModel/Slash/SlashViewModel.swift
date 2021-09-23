//
//  SlashViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxBinding

class SlashViewModel: BaseViewModel, ShouldPresent {
    
    enum ViewToPresent {
        case homeViewController
        case selectLanguageController
        case onBoardingViewController
    }
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    let userService: UserService
    
    override init() {
        self.shouldPresentSubject = .init()
        self.userService = .init()
        super.init()
    }
    
    func determineInitialScreen() {
        if AuthData.shared.isUserLoggedIn, let expiry = AuthData.shared.expiration {
            let now = Date().timeIntervalSince1970
            if expiry <= now {
                AuthData.shared.removeAuthData()
            }
        }
        
        if !PreferenceStore.shared.isAppRunBefore {
            PreferenceStore.shared.isAppRunBefore = true
            self.shouldPresent(.selectLanguageController)
        } else if !FeatureBoarding.areAllFeauturesSeen {
            self.shouldPresentSubject.onNext(.onBoardingViewController)
        } else {
            self.shouldPresentSubject.onNext(.homeViewController)
        }
    }
}
