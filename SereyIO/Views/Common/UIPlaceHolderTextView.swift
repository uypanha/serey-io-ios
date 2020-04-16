//
//  UIPlaceHolderTextView.swift
//  SereyIO
//
//  Created by Panha Uy on 4/14/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

@IBDesignable
class UIPlaceHolderTextView: UITextView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var placeholderText: String? {
        didSet {
            self.placeholder = placeholderText
        }
    }
    
    @IBInspectable var paddingTop: CGFloat = 10 {
        didSet {
            self.updatePadding()
        }
    }
    
    @IBInspectable var paddingBottom: CGFloat = 10 {
        didSet {
            self.updatePadding()
        }
    }
    
    @IBInspectable var paddingLeft: CGFloat = 10 {
        didSet {
            self.updatePadding()
        }
    }
    
    @IBInspectable var paddingRight: CGFloat = 10 {
        didSet {
            self.updatePadding()
        }
    }
    
    var textViewDelegate: UITextViewDelegate?
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        
        self.textViewDelegate?.textViewDidChange?(textView)
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        super.textViewDidEndEditing(textView)
        
        self.textViewDelegate?.textViewDidEndEditing?(textView)
    }
    
    private func updatePadding() {
        self.textContainerInset = UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)
        self.textContainer.lineFragmentPadding = paddingLeft
    }
}

/// Extend UITextView and implemented UITextViewDelegate to listen for changes
extension UITextView: UITextViewDelegate {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                guard let placeHolder = newValue else {
                    return
                }
                self.addPlaceholder(placeHolder)
            }
        }
    }
    
    // The Done Accessory
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding + self.textContainerInset.left
            let labelY = self.textContainerInset.top
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        placeholderLabel.numberOfLines = 0
        
        placeholderLabel.isHidden = self.text.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.resignFirstResponder()
    }
}
