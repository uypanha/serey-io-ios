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
    private let loggedUsernameKey = keyPrefix + "loggedUsernameKey"
    
    static let shared = AuthData()
    private let apnsTokenStore: APNSTokenStore
    var isUserLoggedIn: Bool {
        return self.userToken != nil
    }
    
    var loggedUserModel: UserModel? {
        return UserModel().qeuryFirst()
    }
    
    private(set) var userToken: String? {
        get {
            return Store.secure.value(forKey: loggedUserTokenKey) as? String
        }
        set {
            Store.secure.setValue(newValue, forKey: loggedUserTokenKey)
        }
    }
    
    private(set) var username: String? {
        get {
            return Store.secure.value(forKey: loggedUsernameKey) as? String
        }
        set {
            Store.secure.setValue(newValue, forKey: loggedUsernameKey)
        }
    }
    
    init() {
        self.apnsTokenStore = APNSTokenStore()
    }
    
    func setAuthData(userToken: String, username: String, notify: Bool = true, after timer: TimeInterval = 0) {
        self.userToken = userToken
        self.username = username
        
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
        self.username = nil
        
        AppDelegate.shared?.clearData()
        RealmManager.deleteAll(UserModel.self)
        if(notify) {
            NotificationDispatcher.sharedInstance.dispatch(AppNotification.userDidLogOut)
        }
    }
}
