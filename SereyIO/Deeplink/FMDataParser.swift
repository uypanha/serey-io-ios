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
        if let category = userInfo["Category"] as? String {
            switch(NotificationCategory(rawValue: category)) {
            case .news?:
                if let value = userInfo["Value"] as? String {
                    return DeeplinkType.news(value: value)
                }
            case .reward?:
                if let value = userInfo["Value"] as? String {
                    return DeeplinkType.reward(value: value)
                }
            default:
                break
            }
        }
        return nil
    }
}

enum NotificationCategory: String {
    case news = "NEWS"
    case reward = "REWARD"
}
