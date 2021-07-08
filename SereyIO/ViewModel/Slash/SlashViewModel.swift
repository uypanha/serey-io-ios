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
    }
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    let userService: UserService
    
    override init() {
        self.shouldPresentSubject = .init()
        self.userService = .init()
        super.init()
    }
    
    func updateIpTrace() {
        self.userService.fetchIpTrace()
            .subscribe(onNext: { [weak self] data in
                if let loc = data?.split(separator: "\n").first(where: { $0.contains("loc=") }) {
                    PreferenceStore.shared.currentUserCountryCode = loc.replacingOccurrences(of: "loc=", with: "")
                }
                self?.determineInitialScreen()
            }, onError: { [weak self] error in
                self?.determineInitialScreen()
            }) ~ self.disposeBag
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
