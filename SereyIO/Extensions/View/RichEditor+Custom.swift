//
//  RichEditor+Custom.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/7/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RichEditorView

/// RichEditorOptions is an enum of standard editor actions
public enum CRichEditorOption: RichEditorOption {
    
    case bold
    case italic
    case strike
    case underline
    case header(Int)
    case indent
    case outdent
    case orderedList
    case unorderedList
    case image
    case link
    
    public static let all: [CRichEditorOption] = [
        .bold, .italic,
        .strike, .underline,
        //.header(1),
        .outdent, .indent, .orderedList,
        .unorderedList, .link, .image
    ]
    
    // MARK: RichEditorOption
    
    public var image: UIImage? {
        let image: UIImage?
        switch self {
        case .bold: image = R.image.roundBold()
        case .italic: image = R.image.roundItalic()
        case .strike: image = R.image.roundStrikethrough()
        case .underline: image = R.image.roundUnderlined()
        case .header(let h): image = UIImage(named: "h\(h)")
        case .indent: image = R.image.roundIndentIncrease()
        case .outdent: image = R.image.roundIndentDecrease()
        case .orderedList: image = R.image.roundListNumbered()
        case .unorderedList: image = R.image.roundIstBulleted()
        case .image: image = R.image.roundInsertPhoto()
        case .link: image = R.image.roundInsertLink()
        }
        
        return image
    }
    
    public var title: String {
        switch self {
        case .bold: return NSLocalizedString("Bold", comment: "")
        case .italic: return NSLocalizedString("Italic", comment: "")
        case .strike: return NSLocalizedString("Strike", comment: "")
        case .underline: return NSLocalizedString("Underline", comment: "")
        case .header(let h): return NSLocalizedString("H\(h)", comment: "")
        case .indent: return NSLocalizedString("Indent", comment: "")
        case .outdent: return NSLocalizedString("Outdent", comment: "")
        case .orderedList: return NSLocalizedString("Ordered List", comment: "")
        case .unorderedList: return NSLocalizedString("Unordered List", comment: "")
        case .image: return NSLocalizedString("Image", comment: "")
        case .link: return NSLocalizedString("Link", comment: "")
        }
    }
    
    public var key: RichEditorOptionKey {
        switch self {
        case .bold: return .bold
        case .italic: return .italic
        case .strike: return .strike
        case .underline: return .underline
        case .header(_): return .header
        case .indent: return .indent
        case .outdent: return .outdent
        case .orderedList: return .orderedList
        case .unorderedList: return .unorderedList
        case .image: return .image
        case .link: return .link
        }
    }
    
    public var ignoreHighLight: Bool {
        switch self {
        case .image, .link:
            return true
        default:
            return false
        }
    }
    
    public func action(_ toolbar: RichEditorToolbar) {
        switch self {
        case .bold: toolbar.editor?.bold()
        case .italic: toolbar.editor?.italic()
        case .strike: toolbar.editor?.strikethrough()
        case .underline: toolbar.editor?.underline()
        case .header(let h): toolbar.editor?.header(h)
        case .indent: toolbar.editor?.indent()
        case .outdent: toolbar.editor?.outdent()
        case .orderedList: toolbar.editor?.orderedList()
        case .unorderedList: toolbar.editor?.unorderedList()
        case .image: toolbar.delegate?.richEditorToolbarInsertImage?(toolbar)
        case .link: toolbar.delegate?.richEditorToolbarInsertLink?(toolbar)
        }
    }
}

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
