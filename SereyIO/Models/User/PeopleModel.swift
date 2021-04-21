//
//  PeopleModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/4/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

typealias PeopleModel = String

extension PeopleModel {
    
    var profileViewModel: ProfileViewModel {
        get {
            let firstLetter = first == nil ? "" : "\(first!)"
            let uniqueColor = UIColor(hexString: PFColorHash().hex("\(self)"))
            return ProfileViewModel(shortcut: firstLetter, imageUrl: nil, uniqueColor: uniqueColor)
        }
    }
}
