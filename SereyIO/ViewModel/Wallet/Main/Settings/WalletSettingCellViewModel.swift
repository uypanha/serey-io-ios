//
//  WalletSettingCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/12/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class WalletSettingCellViewModel: ImageTextCellViewModel {
    
    let type: BehaviorRelay<WalletSettingType>
    
    init(_ type: WalletSettingType, _ showSeperatorLine: Bool = false) {
        self.type = .init(value: type)
        super.init(model: type.imageModel, type.indicatorAccessory, type.selectionType, showSeperatorLine: showSeperatorLine)
    }
}

class WalletSettingToggleCellViewModel: ToggleTextCellModel {
    
    let type: BehaviorRelay<WalletSettingType>
    
    init(_ type: WalletSettingType, _ showSeperatorLine: Bool = false) {
        self.type = .init(value: type)
        super.init(textModel: type.imageModel)
    }
}

enum WalletSettingType {
    case profile
    case profileInfo
    case changePassword
    case fingerPrint
    case googleOTP
    
    var cellModel: CellViewModel {
        switch self {
        case .profileInfo, .changePassword:
            return WalletSettingCellViewModel(self, self == .profileInfo)
        case .profile:
            return WalletProfileCellViewModel()
        case .fingerPrint, .googleOTP:
            return WalletSettingToggleCellViewModel(self, self == .googleOTP)
        }
    }
    
    var imageModel: ImageTextModel {
        get {
            switch self {
            case .profileInfo:
                return ImageTextModel(image: R.image.accountIcon(), titleText: AuthData.shared.username ?? "")
            case .changePassword:
                return ImageTextModel(image: R.image.keyIcon(), titleText: "Change Password")
            case .fingerPrint:
                return ImageTextModel(image: R.image.fingerPrintSettingsIcon(), titleText: "Enable Fingerprint")
            case .googleOTP:
                return ImageTextModel(image: R.image.otpIcon(), titleText: "Enable Google Authenticator")
            case .profile:
                return ImageTextModel(image: nil, titleText: nil)
            }
        }
    }
    
    var indicatorAccessory: Bool {
        get {
            switch self {
            case .changePassword:
                return true
            default:
                return false
            }
        }
    }
    
    var selectionType: UITableViewCell.SelectionStyle {
        get {
            switch self {
            case .changePassword:
                return .default
            default:
                return .none
            }
        }
    }
}
