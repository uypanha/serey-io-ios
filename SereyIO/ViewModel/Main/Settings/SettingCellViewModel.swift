//
//  SettingCellViewModel.swift
//  Emergency
//
//  Created by Phanha Uy on 12/4/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import CountryPicker
import FlagKit

class SettingCellViewModel: ImageTextCellViewModel {
    
    let type: BehaviorRelay<SettingType>
    
    init(_ setting: SettingType, _ showSeperatorLine: Bool = false) {
        self.type = BehaviorRelay(value: setting)
        super.init(model: setting.imageModel, setting.indicatorAccessory, setting.selectionType, showSeperatorLine: showSeperatorLine)
    }
}

enum SettingType {
    case myWallet
    case country
    case lagnauge
    case notificationSettings
    case sereyPrice
    case sereyApps
    case version
    
    var imageModel: ImageTextModel {
        get {
            switch self {
            case .myWallet:
                return ImageTextModel(image: R.image.walletIcon(), titleText: R.string.settings.myWallet.localized())
            case .country:
                let country = PreferenceStore.shared.currentCountry
                let image = country == nil ? R.image.globalIcon() : country?.icon
                return ImageTextModel(image: image, imageUrl: country?.iconUrl, titleText: "Country (\(country?.countryName ?? "Global"))")
            case .lagnauge:
                let text = String(format: R.string.settings.language.localized(), LanguageManger.shared.currentLanguage.languageText ?? "")
                return ImageTextModel(image: R.image.languageIcon(), titleText: text)
            case .notificationSettings:
                return ImageTextModel(image: R.image.tabNotification(), titleText: R.string.settings.notificationSettings.localized())
            case .sereyPrice:
                let price = CoinPriceManager.shared.sereyPrice.value
                let priceString = price == 0 ? "Loading..." : "\(price.currencyFormat())"
                let title = "Serey Price <font color=\"red\">($\(priceString))</font>"
                return ImageTextModel(image: R.image.currencyIcon(), titleText: title, isHtml: true)
            case .sereyApps:
                return ImageTextModel(image: R.image.sereyAppsIcon(), titleText: R.string.settings.sereyApps.localized())
            case .version:
                return ImageTextModel(image: R.image.aboutIcon(), titleText: R.string.settings.version.localized(), subTitle: self.subTitle)
            }
        }
    }
    
    var subTitle: String? {
        get {
            switch self {
            case .version:
                return Constants.appVersionName
            default:
                return nil
            }
        }
    }
    
    var indicatorAccessory: Bool {
        get {
            switch self {
            case .version, .sereyPrice:
                return false
            default:
                return true
            }
        }
    }
    
    var selectionType: UITableViewCell.SelectionStyle {
        get {
            switch self {
            case .version:
                return .none
            default:
                return .default
            }
        }
    }
}
