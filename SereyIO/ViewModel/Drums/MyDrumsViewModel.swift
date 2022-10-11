//
//  MyDrumsViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 18/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation

class MyDrumsViewModel: BrowseDrumsViewModel {
    
    init() {
        super.init(author: AuthData.shared.loggedDrumAuthor ?? "", containPostItem: false)
    }
}
