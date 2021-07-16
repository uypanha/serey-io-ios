//
//  AppCoordinator.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2020 Serey IO. All rights reserved.
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
        if PreferenceStore.shared.isAppRunBefore {
            return
        }
        
        // Removing data from keychain
        // TODO: (PŁ) remove all data ??
        AuthData.shared.removeAuthData(notify: false)
        WalletStore.shared.removeAllPassword()
    }
}
