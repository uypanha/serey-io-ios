//
//  AppCoordinator.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

class AppCoordinator {
    
    var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        self.checkInitialStatus()
        let rootViewController = RootViewController()
        self.window.rootViewController = rootViewController
        self.window.makeKeyAndVisible()
    }
    
    fileprivate func checkInitialStatus() {
        if Store.standard.value(forKey: Constants.UserDefaultsKeys.appHasRunBefore.rawValue) as? Bool ?? false {
            return
        }
        
        Store.standard.setValue(true, forKey: Constants.UserDefaultsKeys.appHasRunBefore.rawValue)
        // Removing data from keychain
        // TODO: (PŁ) remove all data ??
        AuthData.shared.removeAuthData(notify: false)
    }
}
