//
//  ReportTypeModel.swift
//  SereyIO
//
//  Created by Panha on 28/1/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation

struct ReportTypeModel: Codable {
    
    let id: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
    }
}

struct ReportTypeResponseModel: Codable {
    
    let reportTypes: [ReportTypeModel]
    
    enum CodingKeys: String, CodingKey {
        case reportTypes = "report_types"
    }
}
