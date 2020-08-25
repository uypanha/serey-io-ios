//
//  WalletSettingsViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/12/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class WalletSettingsViewModel: BaseCellViewModel, CollectionMultiSectionsProviderModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case itemSelected(IndexPath)
    }
    
    enum ViewToPresent {
        case changePasswordController
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let cells: BehaviorRelay<[SectionItem]>
    let cellModels: BehaviorRelay<[SectionType: [CellViewModel]]>
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        self.cells = .init(value: [])
        self.cellModels = .init(value: [:])
        super.init()
        
        setUpRxObservers()
        self.cellModels.accept(self.prepareCellModels())
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
    
    fileprivate func prepareCellModels() -> [SectionType: [CellViewModel]] {
        var sectionItems: [SectionType: [CellViewModel]] = [:]
        
        sectionItems[.profile] = [WalletSettingType.profile.cellModel]
        
        sectionItems[.profileInfo] = [WalletSettingType.profileInfo.cellModel]
        
        let securityItems: [WalletSettingType] = [.changePassword, .fingerPrint, .googleOTP]
        sectionItems[.security] = securityItems.map { $0.cellModel }
        
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
                self.shouldPresent(.changePasswordController)
            default:
                break
            }
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
}
