//
//  NotificationDispatcher.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

@objc
protocol NotificationObserver: class {
    func notificationReceived(_ notification: Notification)
}

extension NotificationObserver {
    func registerForNotifs() {
        NotificationDispatcher.sharedInstance.registerObserver(self)
    }
    
    func unregisterFromNotifs() {
        NotificationDispatcher.sharedInstance.unregisterObserver(self)
    }
}

class NotificationDispatcher {
    
    static let sharedInstance = NotificationDispatcher()
    
    fileprivate static let appNotificationName = Notification.Name("appNotificationName")
    fileprivate static let appNotificationUserInfoKey = "appNotification"
    
    fileprivate init() {
        // singleton
    }
    
    func dispatch(_ notification: AppNotification) {
        let userInfo: [String: Any] = [NotificationDispatcher.appNotificationUserInfoKey: NotificationHolder(notification: notification)]
        NotificationCenter.default.post(name: NotificationDispatcher.appNotificationName, object: nil, userInfo: userInfo)
    }
    
    func registerObserver(_ observer: NotificationObserver) {
        unregisterObserver(observer)
        NotificationCenter.default.addObserver(observer, selector: #selector(NotificationObserver.notificationReceived(_:)),
                                               name: NotificationDispatcher.appNotificationName, object: nil)
    }
    
    func unregisterObserver(_ observer: NotificationObserver) {
        NotificationCenter.default.removeObserver(observer, name: NotificationDispatcher.appNotificationName, object: nil)
    }
}

extension Notification {
    
    var appNotification: AppNotification? {
        if let userInfo = self.userInfo, let notificationHolder = userInfo[NotificationDispatcher.appNotificationUserInfoKey] as? NotificationHolder {
            return notificationHolder.notification
        }
        return nil
    }
}

private class NotificationHolder {
    let notification: AppNotification
    
    init(notification: AppNotification) {
        self.notification = notification
    }
}

