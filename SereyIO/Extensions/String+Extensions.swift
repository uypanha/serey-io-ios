//
//  String+Extensions.swift
//  KongBeiClient
//
//  Created by Phanha Uy on 2/15/19.
//  Copyright © 2020 Serey IO. All rights reserved.
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
    
    func htmlAttributed(size: CGFloat, imageWidth: CGFloat? = nil) -> NSAttributedString? {
        do {
            let htmlCSSString =
                "<!DOCTYPE html>" +
                "<html>" +
                    UtilsHelper.commonCSSStyle(fontSize: size) +
                    UtilsHelper.trixEditorCSSStyle(with: imageWidth) +
                    "<body>" +
                       self +
                    "</body>" +
                "</html>"
            
            guard let data = htmlCSSString.data(using: String.Encoding.utf8) else {
                return nil
            }
            
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil).trailingNewlineChopped(lineSpacing: size - (size / 4))
            
        } catch {
            print("error: ", error)
            return nil
        }
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
