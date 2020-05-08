//
//  Rx+Extensions.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RichEditorView

extension ObservableType where Element == ErrorInfo {
    func asDriverWithDefaultError() -> Driver<ErrorInfo> {
        return asDriver(onErrorJustReturn: ErrorHelper.defaultError())
    }
}

#if os(iOS) || os(tvOS)

extension Reactive where Base: UITextField {
    
    /// Bindable sink for `placeholder` property.
    internal var placeholder: Binder<String?> {
        return Binder(self.base) { uiTextField, placeholder in
            uiTextField.placeholder = placeholder
        }
    }
    
}

extension Reactive where Base : RichEditorView {
    
    /// Bindable sink for `html` property.
    public var html: Binder<String?> {
        return Binder(self.base) { richEditorView, html in
            richEditorView.html = html ?? ""
        }
    }
    
}

#endif
