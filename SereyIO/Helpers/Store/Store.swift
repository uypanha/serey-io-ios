//
//  Store.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import Foundation

class Store {
    
    static let standard: SimpleStore = DefaultsStore()
    static let secure: SimpleStore = KeychainStore()
    
}
