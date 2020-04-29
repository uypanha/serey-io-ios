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
    private let tokenExpiration = keyPrefix + "tokenExpiration"
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
    
    private(set) var expiration: TimeInterval? {
        get {
            return Store.secure.value(forKey: tokenExpiration) as? TimeInterval
        }
        set {
            Store.secure.setValue(newValue, forKey: tokenExpiration)
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
        
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .hour, value: 24, to: Date())
        self.expiration = date?.timeIntervalSince1970 ?? 0
        
        apnsTokenStore.saveToken()
        
        if (notify) {
            DispatchQueue.main.asyncAfter(deadline: .now() + timer) {
                NotificationDispatcher.sharedInstance.dispatch(AppNotification.userDidLogin)
            }
        }
    }
    
    func removeAuthData(notify: Bool = true) {
        apnsTokenStore.removeCurrentToken(username: self.username)
        
        self.userToken = nil
        self.username = nil
        self.expiration = nil
        
        AppDelegate.shared?.clearData()
        RealmManager.deleteAll(UserModel.self)
        if(notify) {
            NotificationDispatcher.sharedInstance.dispatch(AppNotification.userDidLogOut)
        }
    }
}
