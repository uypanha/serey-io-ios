//
//  NotificationSettingsViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/28/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class NotificationSettingsViewModel: BaseViewModel, CollectionMultiSectionsProviderModel {
    
    let cells: BehaviorRelay<[SectionItem]>
    
    override init() {
        self.cells = BehaviorRelay(value: [])
        super.init()
        
        setUpRxObservers()
        self.cells.accept(prepareCells())
    }
}

// MARK: Preparations & Tools
extension NotificationSettingsViewModel {
    
    enum NotificationItem {
        case generalNotification
        
        var cellModel: CellViewModel {
            switch self {
            case .generalNotification:
                return NotificationSettingCellViewModel(self)
            }
        }
        
        var imageViewModel: ImageTextModel {
            switch self  {
            case .generalNotification:
                return ImageTextModel(image: R.image.tabNotification(), titleText: R.string.notifications.pushNotification.localized())
            }
        }
        
        var isOn: Bool {
            switch self {
            case .generalNotification:
                return !PreferenceStore.shared.userDisabledNotifs
            }
        }
    }
    
    func prepareCells() -> [SectionItem] {
        let cells = [NotificationItem.generalNotification].map { $0.cellModel }
        cells.forEach { cellModel in
            if let cellModel = cellModel as? NotificationSettingCellViewModel {
                self.setUpNotificationCellObservers(cellModel)
            }
        }
        return [SectionItem(items: cells)]
    }
}

// MARK: - SetUp RxObservers
extension NotificationSettingsViewModel {
    
    func setUpRxObservers() {
    }
    
    func setUpNotificationCellObservers(_ cellModel: NotificationSettingCellViewModel) {
        cellModel.shouldUpdateToggle.asObservable()
            .subscribe(onNext: { (type, isOn) in
                switch type {
                case .generalNotification:
                    PreferenceStore.shared.setNotification(isOn)
                }
            }) ~ cellModel.disposeBag
    }
}

// MARK: - Notification Toggle Cell
class NotificationSettingCellViewModel: ToggleTextCellModel {
    
    let shouldUpdateToggle: PublishSubject<(NotificationSettingsViewModel.NotificationItem, Bool)>
    let type: NotificationSettingsViewModel.NotificationItem
    
    init(_ type: NotificationSettingsViewModel.NotificationItem) {
        self.type = type
        self.shouldUpdateToggle = PublishSubject()
        super.init(textModel: type.imageViewModel, isOn: type.isOn)
    }
    
    override func didToggleChanged(_ isOn: Bool) {
        self.shouldUpdateToggle.onNext((type, isOn))
    }
}
