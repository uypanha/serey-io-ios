//
//  APNSTokenStore.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

class APNSTokenStore {
    
    private let disposeBag: DisposeBag
    
    init() {
        self.disposeBag = DisposeBag()
    }
    
    func saveToken(_ token: String? = nil) {
        guard AuthData.shared.isUserLoggedIn else { return }
        checkForCurrentFCMToken { (fcmToken) in
            var firebaseToken: String? = token
            if firebaseToken == nil {
                firebaseToken = fcmToken
            }
            
            guard firebaseToken != nil else { return }
            
//            PushService().subscribeToNotification(token: firebaseToken!, true)
//                .subscribe(onNext: { _ in
//                    log.debug("APNS token sent to server")
//                }, onError: { error in
//                    log.error("Error while sending APNS token to server: \(error)")
//                }).disposed(by: self.disposeBag)
        }
    }
    
    func removeCurrentToken(accessToken: String?, completion: @escaping () -> Void = {}) {
        checkForCurrentFCMToken { (token) in
            guard token != nil else { return }
            
//            PushService().subscribeToNotification(token: token!, false, accessToken: accessToken)
//                .subscribe(onNext: { _ in
//                    log.debug("APNS token removed from server")
//                }, onError: { (error) in
//                    log.error("Error while removing APNS token from server: \(error)")
//                }).disposed(by: self.disposeBag)
            completion()
        }
    }
    
    private func checkForCurrentFCMToken(completion: @escaping (String?) -> Void) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
                completion(nil)
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                completion(result.token)
            }
        }
    }
}

