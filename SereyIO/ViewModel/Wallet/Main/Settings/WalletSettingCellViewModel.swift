//
//  WalletSettingCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/12/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import LocalAuthentication

class WalletSettingCellViewModel: ImageTextCellViewModel {
    
    let type: BehaviorRelay<WalletSettingType>
    
    init(_ type: WalletSettingType, _ showSeperatorLine: Bool = false) {
        self.type = .init(value: type)
        super.init(model: type.imageModel, type.indicatorAccessory, type.selectionType, showSeperatorLine: showSeperatorLine)
    }
}

class WalletSettingToggleCellViewModel: ToggleTextCellModel {
    
    let type: BehaviorRelay<WalletSettingType>
    let didToggledUpdated: PublishSubject<(Bool, WalletSettingType)>
    
    init(_ type: WalletSettingType, isOn: Bool, _ showSeperatorLine: Bool = false) {
        self.type = .init(value: type)
        self.didToggledUpdated = .init()
        super.init(textModel: type.imageModel, isOn: isOn)
    }
    
    override func didToggleChanged(_ isOn: Bool) {
        self.didToggledUpdated.onNext((isOn, self.type.value))
    }
}

enum WalletSettingType {
    case profile
    case profileInfo
    case changePassword
    case biometry
    case googleOTP
    
    var cellModel: CellViewModel {
        switch self {
        case .profileInfo, .changePassword:
            return WalletSettingCellViewModel(self, self == .profileInfo)
        case .profile:
            return WalletProfileCellViewModel()
        case .biometry, .googleOTP:
            let isOn = self == .googleOTP ? WalletPreferenceStore.shared.googleOTPEnabled : self == .biometry ? WalletPreferenceStore.shared.biometryEnabled : false
            return WalletSettingToggleCellViewModel(self, isOn: isOn, self == .googleOTP)
        }
    }
    
    var imageModel: ImageTextModel {
        get {
            switch self {
            case .profileInfo:
                return ImageTextModel(image: R.image.accountIcon(), titleText: AuthData.shared.username ?? "")
            case .changePassword:
                return ImageTextModel(image: R.image.keyIcon(), titleText: "Change Password")
            case .biometry:
                let biometricType = LAContext().biometricType
                let image = biometricType.iconImage
                return ImageTextModel(image: image, titleText: "Enable \(biometricType.settingTitle)")
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
