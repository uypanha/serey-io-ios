//
//  Codable.swift
//  SereyIO
//
//  Created by Panha Uy on 8/4/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

extension Encodable {
    
    func toJsonString() -> String? {
        if let jsonData = try? JSONEncoder().encode(self) {
            let jsonString = String(data: jsonData, encoding: .utf8)!
            return jsonString
        }
        return nil
    }
}
