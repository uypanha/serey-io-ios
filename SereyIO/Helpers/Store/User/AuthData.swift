//
//  AuthData.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import Foundation

class AuthData {
    
    private static let keyPrefix = "authenticationData."
    private let loggedUserTokenKey = keyPrefix + "loggedUserToken"
    
    static let shared = AuthData()
    private let apnsTokenStore: APNSTokenStore
    var isUserLoggedIn: Bool {
        return self.userToken != nil
    }
    
//    var loggedUserModel: UserModel? {
//        return UserModel().qeuryFirst()
//    }
    
    private(set) var userToken: String? {
        get {
            return Store.secure.value(forKey: loggedUserTokenKey) as? String
        }
        set {
            Store.secure.setValue(newValue, forKey: loggedUserTokenKey)
        }
    }
    
    init() {
        self.apnsTokenStore = APNSTokenStore()
    }
    
    func setAuthData(userToken: String, notify: Bool = true, after timer: TimeInterval = 0) {
        self.userToken = userToken
        
        apnsTokenStore.saveToken()
        
        if (notify) {
            DispatchQueue.main.asyncAfter(deadline: .now() + timer) {
                NotificationDispatcher.sharedInstance.dispatch(AppNotification.userDidLogin)
            }
        }
    }
    
    func removeAuthData(notify: Bool = true) {
        apnsTokenStore.removeCurrentToken(accessToken: self.userToken)
        
        self.userToken = nil
        
        AppDelegate.shared?.clearData()
        if(notify) {
            NotificationDispatcher.sharedInstance.dispatch(AppNotification.userDidLogOut)
        }
    }
}
