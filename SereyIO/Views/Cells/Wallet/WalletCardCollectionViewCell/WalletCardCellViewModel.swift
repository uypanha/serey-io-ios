//
//  WalletCardCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 7/1/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class WalletCardCellViewModel: CellViewModel {
    
    let type: WalletViewModel.WalletType
    
    let titleText: BehaviorSubject<String?>
    let cardColor: BehaviorSubject<UIColor?>
    let valueText: BehaviorSubject<String?>
    
    init(_ type: WalletViewModel.WalletType) {
        self.type = type
        
        self.titleText = .init(value: type.title)
        self.cardColor = .init(value: type.cardColor)
        self.valueText = .init(value: nil)
        super.init()
    }
}
