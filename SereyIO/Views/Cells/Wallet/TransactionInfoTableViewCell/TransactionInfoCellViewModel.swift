//
//  TransactionInfoCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 9/9/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class TransactionInfoCellViewModel: CellViewModel {
    
    let typeTitle: BehaviorSubject<String?>
    let typeDescription: BehaviorSubject<String?>
    
    init(title: String, description: String) {
        self.typeTitle = .init(value: title)
        self.typeDescription = .init(value: description)
        super.init()
    }
}
