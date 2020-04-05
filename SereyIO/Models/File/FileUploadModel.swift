//
//  FileUploadModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/31/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import ObjectMapper

class FileUploadModel: Mappable {
    
    var responseCode: Int = 0
    var status: String = ""
    var url: String = ""
    
    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        self.responseCode   <- map["responseCode"]
        self.status         <- map["status"]
        self.url            <- map["url"]
    }
}
