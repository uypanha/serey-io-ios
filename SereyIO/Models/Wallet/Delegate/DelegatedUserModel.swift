//
//  DelegatedUserModel.swift
//  SereyIO
//
//  Created by Panha Uy on 12/10/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit

struct DelegatedUserModel: Codable {
    
    let userName: String
    let amount: String
    let date: String
    let imageUrl: String?
    
    var profileViewModel: ProfileViewModel {
        return .init(shortcut: self.userName.first?.description ?? "", imageUrl: .init(string: self.imageUrl ?? ""), uniqueColor: UIColor(hexString: PFColorHash().hex("\(userName)")))
    }
    
    enum CodingKeys: String, CodingKey {
        case userName = "username"
        case amount
        case date
        case imageUrl = "image_url"
    }
}
