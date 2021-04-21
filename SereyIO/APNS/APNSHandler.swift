//
//  APNSHandler.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseMessaging
import FirebaseInstanceID

enum APNSNotificationType: String {
    case local = "local"
}

protocol APNSNotificationHandler: class {
    func canHandleNotification(type: APNSNotificationType?, userInfo: [AnyHashable: Any], isExternal: Bool) -> Bool
    func handleNotification(type: APNSNotificationType?, userInfo: [AnyHashable: Any], isExternal: Bool)
}

/*
 * This class handle system push notifications.
 */
class APNSHandler: NSObject {
    
    fileprivate weak var application: UIApplication?
    fileprivate lazy var tokenStore = APNSTokenStore()
    private var messageHandlers = [APNSNotificationHandler]()
    
    required init(withApplication application: UIApplication) {
        self.application = application
        super.init()
        
        configureFirebaseApp()
    }
    
    fileprivate func configureFirebaseApp() {
        #if DEVELOPMENT
            let filePath = R.file.googleServiceInfoDevelopmentPlist()!.path
        #else
            let filePath = R.file.googleServiceInfoReleasePlist()!.path
        #endif
        
        if let options = FirebaseOptions(contentsOfFile: filePath) {
            FirebaseApp.configure(options: options)
            Messaging.messaging().delegate = self
        }
    }
    
    // MARK: - Handlers Management
    func registerNotificationHandler(_ handler: APNSNotificationHandler) {
        unregisterNotificationHandler(handler)
        messageHandlers.append(handler)
    }
    
    func unregisterNotificationHandler(_ handler: APNSNotificationHandler) {
        guard let index = messageHandlers.index(where: { $0 === handler }) else { return }
        messageHandlers.remove(at: index)
    }
    
    fileprivate func handleRecivedNotification(_ userInfo: [AnyHashable: Any], from userTap: Bool) {
        logNotification(userInfo: userInfo)
        
        let isExternalPush = userTap || application?.applicationState != .active
        
        let eventType = self.prepareEventType(userInfo)
        
        for handler in messageHandlers {
            if handler.canHandleNotification(type: eventType, userInfo: userInfo, isExternal: isExternalPush) {
                handler.handleNotification(type: eventType, userInfo: userInfo, isExternal: isExternalPush)
            }
        }
    }
    
    func registerAPNS() {
        registerForRemoteNotifs()
    }
    
    func unregisterAPNS() {
        unregisterForRemoteNotifs()
    }
}

// MARK: - Preparation/Register
extension APNSHandler {
    
    fileprivate func logNotification(userInfo: [AnyHashable: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            let pushString = (String(bytes: jsonData, encoding: String.Encoding.utf8) ?? "")
            //            print(pushString)
            log.debug("PUSH: " + pushString)
        } catch {
            log.error(error.localizedDescription)
        }
    }
    
    fileprivate func registerForRemoteNotifs() {
        guard let application = application else { return }
        
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    fileprivate func unregisterForRemoteNotifs() {
        guard let application = application else { return }
        application.unregisterForRemoteNotifications()
    }
    
    fileprivate func prepareEventType(_ userInfo: [AnyHashable: Any]) -> APNSNotificationType? {
        //        if let category = (userInfo["aps"] as? [AnyHashable: Any])?[Constants.notificationTypeKey] as? String {
        //            let arrays = category.split(separator: "/")
        //            if arrays.count > 2 {
        //                let eventTypeStr = arrays[arrays.count - 2]
        ////                let id = arrays[arrays.count - 1]
        //                return APNSNotificationType(rawValue: String(eventTypeStr))
        //            }
        //        }ter
        
        return nil
    }
}

// MARK: - AppDelegate
extension APNSHandler {
    
    func application(didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        handleRecivedNotification(userInfo, from: false)
    }
    
    func application(didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02.2hhx", $1)})
        log.info("APNs token retrieved: \(deviceTokenString)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func applicationDidBecomeActive() {
        connectToFcm()
        Deeplinker.checkDeepLink()
    }
    
    func applicationDidEnterBackground() {
        log.info("Disconnected from FCM.")
    }
    
    func applicationDidFailToRegisterForRemoteNotifications(withError error: Error) {
        log.error("APNS token error: \(error)")
    }
}

// MARK: - Firebase
extension APNSHandler {
    
    func connectToFcm() {
        // Won't connect since there is no token
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let token = token {
                print("Remote instance ID token: \(token)")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension APNSHandler: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        handleRecivedNotification(userInfo, from: false)
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        handleRecivedNotification(userInfo, from: true)
        
        if (application?.applicationState == .active) {
            Deeplinker.checkDeepLink()
        }
        
        // Change this to your preferred presentation option
        completionHandler()
    }
}

// MARK: - FIRMessagingDelegate
extension APNSHandler: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = Messaging.messaging().fcmToken {
            tokenStore.saveToken(token)
        }
    }
    
//    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
//        log.debug(remoteMessage.appData)
//    }
}
