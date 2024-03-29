//
//  WalletCardCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 7/1/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class WalletCardCellViewModel: CellViewModel, ShimmeringProtocol {
    
    let type: WalletType?
    
    let titleText: BehaviorSubject<String?>
    let cardColor: BehaviorSubject<UIColor?>
    let valueText: BehaviorSubject<String?>
    let valueUsdText: BehaviorSubject<String?>
    let isShimmering: BehaviorRelay<Bool>
    
    init(_ type: WalletType?) {
        self.type = type
        
        self.titleText = .init(value: type?.title)
        self.cardColor = .init(value: type?.cardColor)
        self.valueText = .init(value: type?.value)
        self.valueUsdText = .init(value: type?.valueUSD)
        self.isShimmering = .init(value: false)
        super.init()
    }
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil)
        self.isShimmering.accept(isShimmering)
    }
}
