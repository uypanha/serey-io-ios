//
//  FeatureBoarding.swift
//  SereyIO
//
//  Created by Panha Uy on 4/28/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

enum FeatureBoarding: CaseIterable {
    
    case shareAndEarn
    case transparency
    case walletAndMarketPlace
    
    var image: UIImage? {
        switch self {
        case .shareAndEarn:
            return R.image.shareaAndEarn()
        case .transparency:
            return R.image.transparency()
        case .walletAndMarketPlace:
            return R.image.walletMarketplace()
        }
    }
    
    var title: String {
        switch self  {
        case .shareAndEarn:
            return "Share & Earn"
        case .transparency:
            return "Transparency"
        case .walletAndMarketPlace:
            return "Wallet & Marketplace"
        }
    }
    
    var message: String {
        switch self {
        case .shareAndEarn:
            return "Earn Serey coins by posting and sharing content."
        case .transparency:
            return "All posts on Serey will be permanently stored on the Serey decentralized blockchain."
        case .walletAndMarketPlace:
            return "Download the Serey Wallet to send and receive coins or go to the Serey marketplace to buy and sell products."
        }
    }
}
