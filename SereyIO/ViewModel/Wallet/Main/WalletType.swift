//
//  WalletType.swift
//  SereyIO
//
//  Created by Panha Uy on 8/5/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

enum WalletType {
    case coin(coins: String?)
    case power(power: String?)
    
    var title: String {
        switch self {
        case .coin:
            return "SEREY COIN"
        case .power:
            return "SEREY POWER"
        }
    }
    
    var cardColor: UIColor? {
        switch self {
        case .coin:
            return UIColor(hexString: "2F3C4D")
        case .power:
            return UIColor(hexString: "00BFA5")
        }
    }
    
    var value: String? {
        switch self {
        case .coin(let coins):
            return coins
        case .power(let power):
            return power
        }
    }
}
