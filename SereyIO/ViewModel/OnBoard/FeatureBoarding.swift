//
//  FeatureBoarding.swift
//  SereyIO
//
//  Created by Panha Uy on 4/28/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

enum FeatureBoarding: CaseIterable {
    
//    case shareAndEarn
    case transparency
//    case walletAndMarketPlace
    
    var image: UIImage? {
        switch self {
//        case .shareAndEarn:
//            return R.image.shareaAndEarn()
        case .transparency:
            return R.image.transparency()
//        case .walletAndMarketPlace:
//            return R.image.walletMarketplace()
        }
    }
    
    var title: String {
        switch self  {
//        case .shareAndEarn:
//            return R.string.onBoard.shareAndEarn.localized()
        case .transparency:
            return R.string.onBoard.transparency.localized()
//        case .walletAndMarketPlace:
//            return R.string.onBoard.walletMarketplace.localized()
        }
    }
    
    var message: String {
        switch self {
//        case .shareAndEarn:
//            return R.string.onBoard.shareAndEarnMessage.localized()
        case .transparency:
            return R.string.onBoard.transparencyMessage.localized()
//        case .walletAndMarketPlace:
//            return R.string.onBoard.walletMarketplaceMessage.localized()
        }
    }
}
