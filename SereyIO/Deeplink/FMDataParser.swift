//
//  FMDataParser.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

class FMDataParser {
    static let shared = FMDataParser()
    private init() { }
    
    func parseDeepLink(_ userInfo: [AnyHashable: Any]) -> DeeplinkType? {
        if let apsInfo = userInfo["aps"] as? [AnyHashable: Any] {
            if let permlink = apsInfo["permlink"] as? String, let author = apsInfo["author"] as? String {
                return .post(permlink: permlink, author: author)
            }
            
            if let followFromUsername = apsInfo["followFromUsername"] as? String {
                return .followFrom(username: followFromUsername)
            }
        }
        
        if let permlink = userInfo["permlink"] as? String, let author = userInfo["author"] as? String {
            return .post(permlink: permlink, author: author)
        }
        
        if let followFromUsername = userInfo["followFromUsername"] as? String {
            return .followFrom(username: followFromUsername)
        }
        
        return nil
    }
}
