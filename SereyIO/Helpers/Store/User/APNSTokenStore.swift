//
//  APNSTokenStore.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

class APNSTokenStore {
    
    private let disposeBag: DisposeBag
    private let pushService: PushService = PushService()
    
    init() {
        self.disposeBag = DisposeBag()
    }
    
    func saveToken(_ token: String? = nil) {
        guard AuthData.shared.isUserLoggedIn else { return }
        guard !PreferenceStore.shared.userDisabledNotifs else { return }
        
        checkForCurrentFCMToken { (fcmToken) in
            var firebaseToken: String? = token
            if firebaseToken == nil {
                firebaseToken = fcmToken
            }
            
            guard let token = firebaseToken else { return }
            
            self.pushService.register(AuthData.shared.username ?? "", token)
                .subscribe(onNext: { [weak self] data in
                    log.debug("APNS token sent to server")
                    if (data.status.code == 1) {
                        // Already Register
                        self?.updateToken(token)
                    }
                }, onError: { error in
                    log.error("Error while sending APNS token to server: \(error)")
                }).disposed(by: self.disposeBag)
        }
    }
    
    private func updateToken(_ token: String) {
        self.pushService.update(AuthData.shared.username ?? "", token)
            .subscribe(onNext: { data in
                log.debug("APNS token sent to server")
            }, onError: { error in
                log.error("Error while sending APNS token to server: \(error)")
            }).disposed(by: self.disposeBag)
    }
    
    func removeCurrentToken(username: String?, completion: @escaping () -> Void = {}) {
        checkForCurrentFCMToken { (token) in
            guard token != nil else { return }
            
            self.pushService.remove(AuthData.shared.username ?? "")
                .subscribe(onNext: { data in
                    log.debug("APNS token sent to server")
                }, onError: { error in
                    log.error("Error while sending APNS token to server: \(error)")
                }).disposed(by: self.disposeBag)
            completion()
        }
    }
    
    private func checkForCurrentFCMToken(completion: @escaping (String?) -> Void) {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
                completion(nil)
            } else if let token = token {
                print("Remote instance ID token: \(token)")
                completion(token)
            }
        }
    }
}

