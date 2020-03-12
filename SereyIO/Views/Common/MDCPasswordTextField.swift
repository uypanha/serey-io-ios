//
//  MDCPasswordTextField.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/12/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import MaterialComponents

class MDCPasswordTextField: MDCTextField {

    lazy var disposeBag = DisposeBag()
    lazy var passwordToggleImageView: UIImageView? = { [unowned self] in
        return self.preparePasswordImageView()
    }()
    
    fileprivate var passwordToggleGesture: UITapGestureRecognizer? = nil {
        didSet {
            guard let passwordToggleGesture = self.passwordToggleGesture else {
                return
            }
            
            self.passwordToggleImageView?.isUserInteractionEnabled = true
            self.passwordToggleImageView?.addGestureRecognizer(passwordToggleGesture)
        }
    }
    
    override var isSecureTextEntry: Bool {
        didSet {
            if isFirstResponder {
                _ = becomeFirstResponder()
            }
        }
    }

    override func becomeFirstResponder() -> Bool {
        let success = super.becomeFirstResponder()
        if isSecureTextEntry, let text = self.text {
            self.text?.removeAll()
            insertText(text)
        }
        return success
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.trailingView = self.passwordToggleImageView
        self.passwordToggleGesture = UITapGestureRecognizer()
        self.rightViewMode = .whileEditing
        
        self.isSecureTextEntry = false
        togglePasswordInputType()
        setUpRxObservers()
    }
    
    private func preparePasswordImageView() -> UIImageView {
        if #available(iOS 13.0, *) {
            return UIImageView(image: R.image.eyeClosedIcon(), highlightedImage: R.image.eyeClosedIcon()?.withTintColor(UIColor.lightGray))
        } else {
            return UIImageView(image: R.image.eyeClosedIcon())
        }
    }
    
    private func togglePasswordInputType() {
        self.isSecureTextEntry.toggle()
        if #available(iOS 11.0, *) {
            self.textContentType = self.isSecureTextEntry ? .password : .none
        }
        
        self.passwordToggleImageView?.image = self.isSecureTextEntry ? R.image.eyeClosedIcon() : R.image.eyeOpenIcon()
    }
    
    private func setUpRxObservers() {
        self.passwordToggleGesture?.rx.event.bind(onNext: { [weak self] recognizer in
            self?.togglePasswordInputType()
        }).disposed(by: self.disposeBag)
    }
}
