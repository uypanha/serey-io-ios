//
//  FireBaseHandler.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

class FireBaseHandler: APNSNotificationHandler {
    
    func canHandleNotification(type: APNSNotificationType?, userInfo: [AnyHashable: Any], isExternal: Bool) -> Bool {
        guard isExternal || type == .local else { return false }
        
        return (userInfo["aps"] as? [AnyHashable: Any]) != nil
    }
    
    func handleNotification(type: APNSNotificationType?, userInfo: [AnyHashable: Any], isExternal: Bool) {
        guard let _ = (userInfo["aps"] as? [AnyHashable: Any]) else { return }
        
        Deeplinker.handldNotificationData(userInfo)
    }
}
