//
//  LanguageCellViewModel.swift
//  Emergency
//
//  Created by Phanha Uy on 9/21/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LanguageCellViewModel: ImageTextCellViewModel {
    
    let isSelected: BehaviorSubject<Bool>
    let language: Languages
    
    init(language: Languages, _ indicatorAccessory: Bool = true) {
        self.language = language
        let model = language.languageModel
        self.isSelected = BehaviorSubject(value: model.isSelected)
        super.init(model: model, indicatorAccessory)
    }
}
