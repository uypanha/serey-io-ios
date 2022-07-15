//
//  NoMorePostCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 12/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class NoMorePostCellViewModel: CellViewModel {
    
    let title: BehaviorRelay<String?>
    
    init(_ title: String) {
        self.title = .init(value: title)
        super.init()
    }
}
