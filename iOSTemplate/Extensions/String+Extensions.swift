//
//  String+Extensions.swift
//  KongBeiClient
//
//  Created by Phanha Uy on 2/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

extension String {
    
    func validate(with pattern: String) -> Bool {
        if pattern.isEmpty {
            return true
        }
        
        let test = NSPredicate(format:"SELF MATCHES %@", pattern)
        return test.evaluate(with: self)
    }
}

// Marks: - Case Converter
extension String {
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
