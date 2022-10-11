//
//  NSAttributedString+Extensions.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/12/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

extension NSAttributedString {
    
    func trailingNewlineChopped(lineSpacing: CGFloat) -> NSAttributedString {
        return self.trimmedAttributedString(set: CharacterSet.newlines)
    }
    
    fileprivate func trimmedAttributedString(set: CharacterSet) -> NSMutableAttributedString {
        
        let invertedSet = set.inverted
        
        var range = (string as NSString).rangeOfCharacter(from: invertedSet)
        let loc = 0//range.length > 0 ? range.location : 0
        
        range = (string as NSString).rangeOfCharacter(
            from: invertedSet, options: .backwards)
        let len = (range.length > 0 ? NSMaxRange(range) : string.count) - loc
        
        let r = self.attributedSubstring(from: NSMakeRange(loc, len))
        return NSMutableAttributedString(attributedString: r)
    }
    
    func makeTextTruncatingTail() -> NSMutableAttributedString {
        let text = NSMutableAttributedString(attributedString: self)
        
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byTruncatingTail
        text.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: text.length))
        
        return text
    }
}
