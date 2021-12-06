//
//  LoadingIndicatorController.swift
//  SereyIO
//
//  Created by Phanha Uy on 1/11/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

protocol LoadingIndicatorController {
    
    func showLoading(_ message: String?)
    
    func dismissLoading()
}

extension LoadingIndicatorController where Self: UIViewController {
    
    func showLoading(_ message: String? = nil) {
        self.view.endEditing(true)
        SKActivityIndicator.show(message ?? "Loading...")
    }
    
    func dismissLoading() {
        SKActivityIndicator.dismiss()
    }
}
