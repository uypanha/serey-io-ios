//
//  Double+Extension.swift
//  SereyIO
//
//  Created by Mäd on 20/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation

extension Double {
    
    func currencyFormat(_ minimumFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = 4
        formatter.currencySymbol = ""
        if let formattedTipAmount = formatter.string(from: self as NSNumber) {
            return formattedTipAmount
        }
        return String(self)
    }
}
