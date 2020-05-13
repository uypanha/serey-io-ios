//
//  AppNotification.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import Foundation

enum AppNotification {
    
    case userDidLogin
    case userDidLogOut
    case languageChanged
    case postCreated
    case postUpdated(permlink: String, author: String, post: PostModel?)
    case postDeleted(permlink: String, author: String)
}
