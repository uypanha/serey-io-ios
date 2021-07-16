//
//  FeatureBoarding.swift
//  SereyIO
//
//  Created by Panha Uy on 4/28/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

enum FeatureBoarding: String, CaseIterable {
    
//    case shareAndEarn
    case choosePreferedCountry
    case transparency
//    case walletAndMarketPlace
    
    var image: UIImage? {
        switch self {
        case .choosePreferedCountry:
            return R.image.readingImage()
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
        case .choosePreferedCountry:
            return "Prefered Country Articles"
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
        case .choosePreferedCountry:
            return "Our platform provide you the best article in your area."
//        case .shareAndEarn:
//            return R.string.onBoard.shareAndEarnMessage.localized()
        case .transparency:
            return R.string.onBoard.transparencyMessage.localized()
//        case .walletAndMarketPlace:
//            return R.string.onBoard.walletMarketplaceMessage.localized()
        }
    }
}

// MARK: - Properties
extension FeatureBoarding {
    
    var isSeen: Bool {
        return (Store.standard.value(forKey: preferenceKey) as? Bool) ?? false
    }
    
    var preferenceKey: String {
        return "isSeen\(self.rawValue)"
    }
    
    static var areAllFeauturesSeen: Bool {
        return featuresToIntroduce.count == 0
    }
    
    static var featuresToIntroduce: [FeatureBoarding] {
        return self.allCases.filter { !$0.isSeen }
    }
    
    var viewModel: CellViewModel {
        switch self {
        case .choosePreferedCountry:
            return ChooseCountryViewModel(self)
        default:
            return FeatureViewModel(self)
        }
    }
}
