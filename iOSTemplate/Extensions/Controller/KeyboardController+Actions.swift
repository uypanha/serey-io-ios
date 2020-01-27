//
//  KeyboardController+Actions.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol KeyboardController {
    
    func setUpTabSelfToDismissKeyboard(_ enabled: Bool, cancelsTouchesInView: Bool) -> Disposable?
    
    func dismissKeyboard()
}

extension KeyboardController where Self: UIViewController {
    
    func setUpTabSelfToDismissKeyboard(_ enabled: Bool = true, cancelsTouchesInView: Bool = false) -> Disposable? {
        return setUpTabToDismissKeyboard(self.view, enabled, cancelsTouchesInView: cancelsTouchesInView)
    }
    
    func setUpTabToDismissKeyboard(_ view: UIView, _ enabled: Bool = true, cancelsTouchesInView: Bool = false) -> Disposable? {
        if enabled {
            let tapGesture = UITapGestureRecognizer()
            tapGesture.cancelsTouchesInView = cancelsTouchesInView
            view.addGestureRecognizer(tapGesture)
            
            return tapGesture.rx.event.bind(onNext: { [weak self] recognizer in
                self?.dismissKeyboard()
            })
            
        } else {
            view.gestureRecognizers?.forEach { (recognizer) in
                if recognizer is UITapGestureRecognizer {
                    view.removeGestureRecognizer(recognizer)
                }
            }
            view.gestureRecognizers?.removeAll()
        }
        return nil
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
