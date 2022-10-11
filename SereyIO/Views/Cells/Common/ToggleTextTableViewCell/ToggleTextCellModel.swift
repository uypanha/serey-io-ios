//
//  ToggleTextCellModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 12/19/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ToggleTextCellModel: ImageTextCellViewModel, ShouldReactToAction {
    
    enum Action {
        case toggleSwitch
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<ToggleTextCellModel.Action>()
    
    let toggleSwitcher: BehaviorSubject<Bool>
    var isEnabled: Bool = false
    
    init(textModel: ImageTextModel, isOn: Bool = false, showSeperatorLine: Bool = false) {
        self.toggleSwitcher = BehaviorSubject(value: false)
        super.init(model: textModel, false, .default, showSeperatorLine: showSeperatorLine)
        
        self.isEnabled = isOn
        self.toggleSwitcher.onNext(self.isEnabled)
        
        setUpRxObservers()
    }
    
    func didToggleChanged(_ isOn: Bool) {}
}

// MARK: - Preparations & Tools
fileprivate extension ToggleTextCellModel {
    
    func handleToggleSelection() {
        self.isEnabled = !self.isEnabled
        self.didToggleChanged(self.isEnabled)
    }
}

// MARK: - SetUp RxObservers
fileprivate extension ToggleTextCellModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .toggleSwitch:
                    self?.handleToggleSelection()
                }
            }).disposed(by: self.disposeBag)
    }
}
