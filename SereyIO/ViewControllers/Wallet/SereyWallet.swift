//
//  SereyWallet.swift
//  SereyIO
//
//  Created by Panha Uy on 6/17/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class SereyWallet {
    
    var rootViewController: WalletRootViewController
    
    static var shared: SereyWallet? = {
        return SereyWallet()
    }()
    
    init() {
        self.rootViewController = WalletRootViewController()
    }
    
    static func newInstance() -> SereyWallet {
        self.shared = SereyWallet()
        return self.shared!
    }
}
