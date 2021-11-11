//
//  WalletMenu.swift
//  SereyIO
//
//  Created by Panha Uy on 7/29/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

enum WalletMenu: CaseIterable {
    
    case sendCoin
    case receiveCoin
    case pay
    case powerUp
    case powerDown
    case cancelPower
    case delegatePower
    case cancelDelegate
    case claimReward
    
    static var menuItems: [WalletMenu] {
        return [.sendCoin, .receiveCoin, .pay, .powerUp, .powerDown, .cancelPower, .delegatePower, .cancelDelegate, .claimReward]
    }
    
    var image: UIImage? {
        switch self {
        case .sendCoin:
            return R.image.sendCoinIcon()
        case .receiveCoin:
            return R.image.recieveIcon()
        case .pay:
            return R.image.payIcon()
        case .powerUp:
            return R.image.powerUpIcon()
        case .powerDown:
            return R.image.powerDownIcon()
        case .cancelPower:
            return R.image.cancelPowerDownIcon()
        case .delegatePower:
            return R.image.delegatePowerIcon()
        case .cancelDelegate:
            return R.image.cancelDelegate()
        case .claimReward:
            return R.image.claimRewardIcon()
        }
    }
    
    var title: String {
        switch self {
        case .sendCoin:
            return "Send\nCoin"
        case .receiveCoin:
            return "Receive\nCoin"
        case .pay:
            return "Scan\nQR"
        case .powerUp:
            return "Power\nUp"
        case .powerDown:
            return "Power\nDown"
        case .cancelPower:
            return "Cancel\nPower Down"
        case .delegatePower:
            return "Delegate\nPower"
        case .cancelDelegate:
            return "Cancel\nDelegate"
        case .claimReward:
            return "Claim\nReward"
        }
    }
    
    var subTitle: String {
        switch self {
        case .sendCoin:
            return "To another acc"
        case .receiveCoin:
            return "From another acc"
        case .pay:
            return "Pay another acc"
        case .powerUp:
            return "Up to account"
        case .powerDown:
            return "Down from your acc"
        case .cancelPower:
            return "Cancel power down"
        case .delegatePower:
            return "Delegate your power"
        case .cancelDelegate:
            return "Cancel Delegation"
        case .claimReward:
            return "Claim your reward"
        }
    }
    
    var backgroundColor: UIColor? {
        switch self {
        case .sendCoin:
            return UIColor(hexString: "E5F2DC")
        case .receiveCoin:
            return UIColor(hexString: "FDF3E0")
        case .pay:
            return UIColor(hexString: "EFEFEF")
        case .powerUp:
            return UIColor(hexString: "E5F2DC")
        case .powerDown:
            return UIColor(hexString: "FDF3E0")
        case .cancelPower:
            return UIColor(hexString: "FAE3E2")
        case .delegatePower:
            return UIColor(hexString: "E5F2DC")
        case .cancelDelegate:
            return UIColor(hexString: "FAE3E2")
        case .claimReward:
            return UIColor(hexString: "FDF3E0")
        }
    }
}
