//
//  PowerUpViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/27/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class PowerUpViewModel: BaseViewModel {
    
    let accountTextFieldViewModel: TextFieldViewModel
    let amountTextFieldViewModel: TextFieldViewModel

    override init() {
        self.accountTextFieldViewModel = .textFieldWith(title: R.string.transfer.toAccount.localized() + " *", validation: .notEmpty)
        self.amountTextFieldViewModel = .textFieldWith(title: R.string.transfer.amount.localized() + " *", validation: .notEmpty)
        
        super.init()
    }
}
