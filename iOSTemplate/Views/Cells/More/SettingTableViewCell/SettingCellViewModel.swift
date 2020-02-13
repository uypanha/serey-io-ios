//
//  SettingCellViewModel.swift
//  Emergency
//
//  Created by Phanha Uy on 12/4/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SettingCellViewModel: ImageTextCellViewModel {
    
    let showSeperatorLine: BehaviorSubject<Bool>
    let type: BehaviorRelay<SettingType>
    let subTitle: BehaviorSubject<String?>
    
    init(_ setting: SettingType, _ showSeperatorLine: Bool = false) {
        self.type = BehaviorRelay(value: setting)
        self.showSeperatorLine = BehaviorSubject(value: showSeperatorLine)
        self.subTitle = BehaviorSubject(value: setting.subTitle)
        super.init(model: setting.imageModel, setting.indicatorAccessory, setting.selectionType)
    }
}

enum SettingType {
    case myWallet
    case lagnauge
    case notificationSettings
    case sereyApps
    case version
    
    var imageModel: ImageTextModel {
        get {
            switch self {
            case .myWallet:
                return ImageTextModel(image: R.image.walletIcon(), titleText: R.string.settings.myWallet.localized())
            case .lagnauge:
                let text = String(format: R.string.settings.language.localized(), LanguageManger.shared.currentLanguage.languageText ?? "")
                return ImageTextModel(image: R.image.languageIcon(), titleText: text)
            case .notificationSettings:
                return ImageTextModel(image: R.image.tabNotification(), titleText: R.string.settings.notificationSettings.localized())
            case .sereyApps:
                return ImageTextModel(image: R.image.sereyAppsIcon(), titleText: R.string.settings.sereyApps.localized())
            case .version:
                return ImageTextModel(image: R.image.aboutIcon(), titleText: R.string.settings.version.localized())
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
            case .version:
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
