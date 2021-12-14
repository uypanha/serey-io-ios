//
//  WalletSettingsViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/12/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources
import LocalAuthentication

class WalletSettingsViewModel: BaseUserProfileViewModel, CollectionMultiSectionsProviderModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case itemSelected(IndexPath)
    }
    
    enum ViewToPresent {
        case changePasswordController(ChangePasswordViewModel)
        case activateGoogleOTPContronner(ActivateGoogleOTPViewModel)
        case activeBiometryViewController(ActiveBiometryViewModel)
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let cells: BehaviorRelay<[SectionItem]>
    let cellModels: BehaviorRelay<[SectionType: [CellViewModel]]>
    
    init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        self.cells = .init(value: [])
        self.cellModels = .init(value: [:])
        super.init(AuthData.shared.username ?? "")
        
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension WalletSettingsViewModel {
    
    enum SectionType: CaseIterable {
        case profile
        case profileInfo
        case security
        
        var title: String? {
            switch self {
            case .profileInfo:
                return "Personal Information"
            case .security:
                return "Security"
            default:
                return nil
            }
        }
    }
    
    func loadCells() {
        self.cellModels.accept(self.prepareCellModels())
    }
    
    fileprivate func prepareCellModels() -> [SectionType: [CellViewModel]] {
        var sectionItems: [SectionType: [CellViewModel]] = [:]
        
        sectionItems[.profile] = [WalletSettingType.profile.cellModel]
        
        sectionItems[.profileInfo] = [WalletSettingType.profileInfo.cellModel]
        
        let securityItems: [WalletSettingType] = [.changePassword, .biometry, .googleOTP]
        sectionItems[.security] = securityItems.map { type in
            let cell = type.cellModel
            if let toggledCell = cell as? WalletSettingToggleCellViewModel {
                self.setUpToggleCellObserver(cellModel: toggledCell)
            }
            return cell
        }
        
        return sectionItems
    }
    
    fileprivate func prepareCells(_ cellModels: [SectionType: [CellViewModel]]) -> [SectionItem] {
        var sectionItems: [SectionItem] = []
        
        SectionType.allCases.forEach { type in
            if let cells = cellModels[type] {
                sectionItems.append(SectionItem(model: Section(header: type.title), items: cells))
            }
        }
        
        return sectionItems
    }
}

// MARK: - Action Handlers
fileprivate extension WalletSettingsViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let item = self.item(at: indexPath) as? WalletSettingCellViewModel {
            switch item.type.value {
            case .changePassword:
                let changePasswordViewModel = ChangePasswordViewModel()
                self.shouldPresent(.changePasswordController(changePasswordViewModel))
            default:
                break
            }
        }
    }
    
    func handleToggledSecurityType(isOn: Bool, type: WalletSettingType) {
        switch type {
        case .googleOTP:
            if (isOn) {
                let activateGoogleOTPViewModel = ActivateGoogleOTPViewModel(.settings)
                self.shouldPresent(.activateGoogleOTPContronner(activateGoogleOTPViewModel))
            } else {
                WalletPreferenceStore.shared.disableGoogleOTP()
            }
        case .biometry:
            if (isOn) {
                let biometricType = LAContext().biometricType
                let activeBiometryViewModel = ActiveBiometryViewModel(parent: .settings, biometricType)
                self.shouldPresent(.activeBiometryViewController(activeBiometryViewModel))
            } else {
                WalletPreferenceStore.shared.disableBiometry()
            }
        default:
            break
        }
    }
}

// MARK: - SetUp RxObservers
extension WalletSettingsViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.cellModels.asObservable()
            .map { self.prepareCells($0) }
            .bind(to: self.cells)
            .disposed(by: self.disposeBag)
        
//        self.userInfo.asObservable()
//            .`do`(onNext: { [weak self] userModel in
//                if let userModel = userModel {
//                    self?.setUpUserInfoObservers(userModel)
//                }
//            }).subscribe(onNext: { [unowned self] userModel in
//                self.cellModels.accept(self.prepareCellModels())
//            }).disposed(by: self.disposeBag)
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indexPath):
                    self?.handleItemSelected(indexPath)
                }
            }) ~ self.disposeBag
    }
    
    func setUpToggleCellObserver(cellModel: WalletSettingToggleCellViewModel) {
        cellModel.didToggledUpdated.asObservable()
            .subscribe(onNext: { [weak self] (isOn, type) in
                self?.handleToggledSecurityType(isOn: isOn, type: type)
            }) ~ cellModel.disposeBag

    }
}
