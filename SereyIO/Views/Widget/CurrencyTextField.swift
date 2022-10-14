//
//  CurrencyTextField.swift
//  SereyIO
//
//  Created by Panha Uy on 21/9/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import MaterialComponents
import TLCustomMask

class CurrencyTextField: MDCOutlinedTextField {
    
    var customMask = TLCustomMask()
    
    var viewModel: TextFieldViewModel? {
        didSet {
            guard let viewModel = self.viewModel else { return }
            
            viewModel.bind(withMDC: self)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //If using in SBs
        setup()
    }

    private func setup() {
        self.keyboardType = .decimalPad
        delegate = self
    }
}

extension CurrencyTextField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (range.location == 0 && (string.starts(with: ".") || string.starts(with: ","))) {
            self.viewModel?.value = "0."
            return false
        }
        
        if string.starts(with: ".") || string.starts(with: ",") {
            let text = self.viewModel?.value ?? ""
            if text.contains(".") || text.contains(",") {
                return false
            }
            self.viewModel?.value = text + "."
            return false
        }
        
        if Int(string) != nil {
            return true
        }
        
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                return true
            }
        }
        
        return false
    }
}
