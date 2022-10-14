//
//  URL+Helpers.swift
//  SereyIO
//
//  Created by Panha Uy on 4/1/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

extension URL {
    
    static func temporarySQLiteFileURL() -> URL {
        let applicationSupportPath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
        let dbPath = applicationSupportPath + "/io.serey.cache"
        
        if !FileManager.default.fileExists(atPath: dbPath) {
            try? FileManager.default.createDirectory(atPath: dbPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        let url = URL(fileURLWithPath: dbPath)
        return url.appendingPathComponent("db.sqlite3")
    }
}

// MARK: - Properties
extension URL {
    
    var mimeType: String {
        return MimeType(url: self).value
    }
}
