//
//  AppDelegateHelper.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

class AppDelegateHelper: NSObject {
    
    fileprivate func initFireBaseHandler(apnsHandler: APNSHandler) {
        apnsHandler.registerNotificationHandler(FireBaseHandler())
    }
}

// MARK: - Framework initializers
extension AppDelegateHelper {
    
    func initMessageHandlers(window: UIWindow, apnsHandler: APNSHandler) {
        initFireBaseHandler(apnsHandler: apnsHandler)
    }
}
