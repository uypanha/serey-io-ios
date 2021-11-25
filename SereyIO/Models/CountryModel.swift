//
//  CountryModel.swift
//  SereyIO
//
//  Created by Mäd on 24/11/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit
import CountryPicker
import FlagKit

@objcMembers class CountryModel: Object, Codable {
    
    @objc dynamic var id = ObjectId.generate()
    @objc dynamic var countryName: String = ""
    
    var icon: UIImage? {
        var countryName = self.countryName.contains("Ukraine") ? "Ukraine" : self.countryName
        countryName = countryName.contains("Nederland") ? "Netherlands" : countryName
        let country = CountryManager.shared.country(withName: countryName)
        let flag = Flag(countryCode: country?.countryCode ?? "")
        return flag?.image(style: .roundedRect)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    enum CodingKeys: String, CodingKey {
        case countryName = "country_name"
    }
}
