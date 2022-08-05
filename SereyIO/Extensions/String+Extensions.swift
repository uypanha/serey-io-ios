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
    
    func htmlWithoutCss() -> NSAttributedString? {
        do {
            let htmlCSSString =
                "<!DOCTYPE html>" +
                "<html>" +
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
                                          documentAttributes: nil)
            
        } catch {
            print("error: ", error)
            return nil
        }
    }
    
    var htmlToString: String {
        return htmlWithoutCss()?.string ?? ""
    }
}

// MARK: - Case Converter
extension String {
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

// MARK: - Formater
extension String {
    
    func toDouble() -> Double? {
        let value = self.replacingOccurrences(of: " ", with: "")
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        return formatter.number(from: value)?.doubleValue ?? Double(value)
    }
    
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
}

