//
//  NotificationsResponseModel.swift
//  SereyIO
//
//  Created by Panha Uy on 9/27/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation

struct NotificationsResponseModel: Codable {
    
    let notifications: [NotificationModel]
    let notificationUnreadCount: Int
    
    enum CodingKeys: String, CodingKey {
        case notifications
        case notificationUnreadCount = "notification_unread_count"
    }
}
