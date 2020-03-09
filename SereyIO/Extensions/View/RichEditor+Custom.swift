//
//  RichEditor+Custom.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/7/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RichEditorView

// Marks: - Custom Font for Rich Editor
extension RichEditorView {
    
    func customCssAndJS() {
        /// Loads the custom CSS, swaps out the fonts with those in the bundle, and applies it to the editor
        if let customRichEditorjs = self.addCSSFile(file: "custom_rich_editor_style", { (customCSS) in
//            var newCSS = customCSS
//            let bundle = Bundle.main
            
//            /// Replace the font with the actual location of the font inside our bundle
//            if let fontLocation = bundle.path(forResource: "Ubuntu-Regular", ofType: "ttf") {
//                newCSS = (newCSS as NSString).replacingOccurrences(of: "custom-font.ttf", with: fontLocation)
//            }
            
            return addCSSString(style: customCSS)
        }) {
            self.runJS(customRichEditorjs)
        }
        
        if let commonCSS = self.addCSSFile(file: "common_css", { (customCSS) -> String in
            let newCSS = (customCSS as NSString).replacingOccurrences(of: "(font-size-to-replace)", with: "16")
            return addCSSString(style: newCSS)
        }) {
            self.runJS(commonCSS)
        }
        
//        if let trixEditorCCS = self.addCSSFile(file: "trix-editor", { (customCSS) -> String in
//            return addCSSString(style: customCSS)
//        }) {
//            let widthProperty = "100%"
//            let newCSS = (trixEditorCCS as NSString).replacingOccurrences(of: "(imageMaxWidth)", with: widthProperty)
//            self.runJS(newCSS)
//        }
        
//        if let tributeCSS = self.addCSSFile(file: "custom-tribute", { (customCSS) -> String in
//            return addCSSString(style: customCSS)
//        }) {
//            self.runJS(tributeCSS)
//        }
        
        /// Loads the custom JS, swaps out the fonts with those in the bundle, and applies it to the editor
        if let customJS = readFile(withName: "custom_rich_editor", type: "js") {
            let js = addJSString(js: customJS)
            self.runJS(js)
        }
    }
    
    private func addCSSFile(file: String,_ block: (String) throws -> String = { data in data }) rethrows -> String? {
        /// Loads the custom CSS, swaps out the fonts with those in the bundle, and applies it to the editor
        if let customCSS = readFile(withName: file, type: "css") {
            return try block(customCSS)
        }
        
        return nil
    }
    
    /// Reads a file from the application's bundle, and returns its contents as a string
    /// Returns nil if there was some error
    private func readFile(withName name: String, type: String) -> String? {
        if let filePath = Bundle.main.path(forResource: name, ofType: type) {
            do {
                let file = try String(contentsOfFile: filePath, encoding: .utf8) as String
                return file
            } catch let error {
                print("Error loading \(name).\(type): \(error)")
            }
        }
        return nil
    }
    
    /// Creates a JS string that can be run in the WebView to apply the passed in CSS to it
    func addCSSString(style: String) -> String {
        let css = self.cleanStringForJS(string: style)
        let js = "var css = document.createElement('style'); css.type = 'text/css'; css.innerHTML = '\(css)'; document.body.appendChild(css);"
        return js
    }
    
    /// Creates a JS string that can be run in the WebView to apply the passed in JS to it
    func addJSString(js: String) -> String {
        let script = self.cleanStringForJS(string: js)
        let js = "var script = document.createElement('script'); script.type = 'text/javascript'; script.innerHTML = '\(script)'; document.body.appendChild(script);"
        return js
    }
    
    func cleanStringForJS(string: String) -> String {
        let substitutions = [
            "\"": "\\\"",
            "'": "\\'",
            "\n": "\\\n",
            ]
        
        var output = string
        for (key, value) in substitutions {
            output = (output as NSString).replacingOccurrences(of: key, with: value)
        }
        
        return output
    }
}
