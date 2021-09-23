//
//  WalletMenuCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 7/29/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class WalletMenuCellViewModel: CellViewModel {
    
    let menu: BehaviorRelay<WalletMenu>
    
    let image: BehaviorSubject<UIImage?>
    let title: BehaviorSubject<String?>
    let subTitle: BehaviorSubject<String?>
    let backgroundColor: BehaviorRelay<UIColor?>
    let isEnabled: BehaviorSubject<Bool>
    
    init(_ menu: WalletMenu, isEnabled: Bool = true) {
        self.menu = .init(value: menu)
        
        self.image = .init(value: menu.image)
        self.title = .init(value: menu.title)
        self.subTitle = .init(value: menu.subTitle)
        self.backgroundColor = .init(value: menu.backgroundColor)
        self.isEnabled = .init(value: isEnabled)
        super.init()
    }
}
