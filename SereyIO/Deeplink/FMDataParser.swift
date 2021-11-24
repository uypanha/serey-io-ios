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
        if let type = userInfo["type"] as? String {
            let actor = (userInfo["actor"] as? String) ?? ""
            
            switch type {
            case "FOLLOW":
                return .followFrom(username: actor)
            case "COMMENT", "VOTE":
                if let information = userInfo["information"] as? String {
                    if let jsonData = information.data(using: .utf8) {
                        let jsonDecoder = JSONDecoder()
                        if let data = try? jsonDecoder.decode(NotificationInformationModel.self, from: jsonData) {
                            return .post(permlink: data.postPermlink ?? "", author: data.postAuthor ?? "")
                        }
                    }
                }
            default:
                break
            }
        }
        
        return nil
    }
}
