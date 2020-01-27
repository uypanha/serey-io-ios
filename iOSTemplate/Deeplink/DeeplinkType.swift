//
//  DeeplinkType.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

enum DeeplinkType {
    case news(value: String)
    case reward(value: String)
    case tripFinished(value: String)
    case browser(url: URL)
}

let Deeplinker = DeepLinkManager()
class DeepLinkManager {
    
    fileprivate init() {}
    
    private var deeplinkType: DeeplinkType?
    
    @discardableResult
    func handleShortcut(item: UIApplicationShortcutItem) -> Bool {
        // deeplinkType = ShortcutParser.shared.handleShortcut(item)
        return deeplinkType != nil
    }
    
    @discardableResult
    func handleDeepLink(_ url: URL) -> Bool {
        deeplinkType = DeeplinkParser.shared.parseDeepLink(url)
        return deeplinkType != nil
    }
    
    @discardableResult
    func handldNotificationData(_ userInfo: [AnyHashable: Any]) -> Bool {
        deeplinkType = FMDataParser.shared.parseDeepLink(userInfo)
        return deeplinkType != nil
    }
    
    // check existing deepling and perform action
    func checkDeepLink() {
        AppDelegate.shared?.rootViewController?.deeplink = deeplinkType
        
        // reset deeplink after handling
        self.deeplinkType = nil
    }
}
