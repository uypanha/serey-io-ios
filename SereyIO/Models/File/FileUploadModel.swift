//
//  FileUploadModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/31/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

class FileUploadModel: Codable {
    
    var responseCode: Int = 0
    var status: String = ""
    var url: String = ""
    
    enum CodingKeys: String, CodingKey {
        case responseCode
        case status
        case url
    }
}
