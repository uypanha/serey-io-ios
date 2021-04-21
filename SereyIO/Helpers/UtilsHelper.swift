//
//  UtilsHelper.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/12/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

class UtilsHelper {
    
    public static func commonCSSStyle(fontSize: CGFloat) -> String {
        if let commonCSS = readFile(withName: "common_css", type: "css") {
            var newCSS = commonCSS
            newCSS = (newCSS as NSString).replacingOccurrences(of: "(font-size-to-replace)", with: "\(fontSize)")
            return String(format: "<style>%@</style>", newCSS)
        }
        
        return ""
    }
    
    public static func trixEditorCSSStyle(with imageWidth: CGFloat? = nil) -> String {
        if let trixCSS = readFile(withName: "trix-editor", type: "css") {
            let widthProperty = imageWidth != nil ? "\(imageWidth!)px" : "100%"
            let newCSS = (trixCSS as NSString).replacingOccurrences(of: "(imageMaxWidth)", with: widthProperty)
            return String(format: "<style>%@</style>", newCSS)
        }
        
        return ""
    }
    
    /// Reads a file from the application's bundle, and returns its contents as a string
    /// Returns nil if there was some error
    public static func readFile(withName name: String, type: String) -> String? {
        if let filePath = Bundle.main.path(forResource: name, ofType: type) {
            do {
                let file = try String(contentsOfFile: filePath, encoding: .utf8) as String // NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding) as String
                return file
            } catch let error {
                print("Error loading \(name).\(type): \(error)")
            }
        }
        return nil
    }
}
