//
//  HeaderCellViewModel.swift
//  SereyMarket
//
//  Created by Panha Uy on 5/10/21.
//  Copyright © 2021 Serey Marketplace. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class HeaderCellViewModel: CellViewModel {
    
    let title: BehaviorRelay<String?>
    
    init(_ title: String) {
        self.title = .init(value: title)
        super.init()
    }
}
