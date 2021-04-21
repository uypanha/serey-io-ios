//
//  SecurityMethodCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 6/15/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class SecurityMethodCellViewModel: CellViewModel {
    
    let method: SecurityMethod
    let iconImage: BehaviorSubject<UIImage?>
    let titleText: BehaviorSubject<String?>
    let descriptionText: BehaviorSubject<String?>
    
    init(_ method: SecurityMethod) {
        self.method = method
        self.iconImage = .init(value: method.iconImage)
        self.titleText = .init(value: method.title)
        self.descriptionText = .init(value: method.description)
        super.init(false, .none)
    }
}
