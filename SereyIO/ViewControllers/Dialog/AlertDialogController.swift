//
//  AlertDialogController.swift
//  SereyIO
//
//  Created by Panha Uy on 3/21/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

protocol AlertDialogController {
    
    func showDialog(_ icon: UIImage?, title: String?, message: String?, dismissable: Bool, positiveButton: String?, positiveCompletion: (() -> Void)?, negativeButton: String?, negativeCompletion: (() -> Void)?)
    
    func showDialogError(_ errorInfo: ErrorInfo, positiveButton: String?, positiveCompletion: (() -> Void)?, negativeButton: String?, negativeCompletion: (() -> Void)?)
    
    func showDialog(_ model: AlertDialogModel)
    
    func showActionSheet(_ model: AlertDialogModel)
}

// MARK: - Where Self Extended by UIViewController
extension AlertDialogController where Self: UIViewController {
    
    func showDialog(_ icon: UIImage? = nil, title: String?, message: String?, dismissable: Bool = true, positiveButton: String? = nil, positiveCompletion: (() -> Void)? = nil, negativeButton: String? = nil, negativeCompletion: (() -> Void)? = nil) {
        self.view.endEditing(true)
        
        let alertDialogViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let negativeButton = negativeButton {
            let action = UIAlertAction(title: negativeButton, style: .cancel) { action in
                negativeCompletion?()
            }
            alertDialogViewController.addAction(action)
        }
        
        if let positiveButton = positiveButton {
            let action = UIAlertAction(title: positiveButton, style: .default) { action in
                positiveCompletion?()
            }
            alertDialogViewController.addAction(action)
        }
        
        // dismiss old dialog befire display new one
        self.present(alertDialogViewController, animated: true, completion: nil)
    }
    
    func showDialogError(_ errorInfo: ErrorInfo, positiveButton: String? = R.string.common.confirm.localized(), positiveCompletion: (() -> Void)? = nil, negativeButton: String? = nil, negativeCompletion: (() -> Void)? = nil) {
        let alertDialogViewController = UIAlertController(title: errorInfo.errorTitle, message: errorInfo.error.localizedDescription, preferredStyle: .alert)
        
        if let negativeButton = negativeButton {
            let action = UIAlertAction(title: negativeButton, style: .cancel) { action in
                negativeCompletion?()
            }
            alertDialogViewController.addAction(action)
        }
        
        if let positiveButton = positiveButton {
            let action = UIAlertAction(title: positiveButton, style: .default) { action in
                positiveCompletion?()
            }
            alertDialogViewController.addAction(action)
        }
        
        // dismiss old dialog befire display new one
        self.present(alertDialogViewController, animated: true, completion: nil)
    }
    
    func showDialog(_ model: AlertDialogModel) {
        self.view.endEditing(true)
        
        let alertDialogViewController = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        alertDialogViewController.view.tintColor = .color(.primary)
        
        model.actions.forEach { action in
            let alertAction = UIAlertAction(title: action.title, style: action.actionStyle) { _ in
                action.completion()
            }
            
            alertDialogViewController.addAction(alertAction)
        }
        
        if model.actions.isEmpty {
            let alertAction = UIAlertAction(title: R.string.common.confirm.localized(), style: .default)
            alertDialogViewController.addAction(alertAction)
        }
        
        // dismiss old dialog befire display new one
        self.present(alertDialogViewController, animated: true, completion: nil)
    }
    
    func showActionSheet(_ model: AlertDialogModel) {
        self.view.endEditing(true)
        
        let alertDialogViewController = UIAlertController(title: model.title, message: model.message, preferredStyle: .actionSheet)
        alertDialogViewController.view.tintColor = .color(.primary)
        
        model.actions.forEach { action in
            let alertAction = UIAlertAction(title: action.title, style: action.actionStyle) { _ in
                action.completion()
            }
            
            alertDialogViewController.addAction(alertAction)
        }
        
        let alertAction = UIAlertAction(title: R.string.common.cancel.localized(), style: .cancel)
        alertDialogViewController.addAction(alertAction)
        
        // dismiss old dialog befire display new one
        self.present(alertDialogViewController, animated: true, completion: nil)
    }
}
