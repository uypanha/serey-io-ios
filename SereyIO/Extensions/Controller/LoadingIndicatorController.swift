//
//  LoadingIndicatorController.swift
//  SereyIO
//
//  Created by Phanha Uy on 1/11/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol LoadingIndicatorController: NVActivityIndicatorViewable {
    
    func showLoading(_ message: String?)
    
    func dismissLoading()
}

extension LoadingIndicatorController where Self: UIViewController {
    
    func showLoading(_ message: String? = nil) {
        self.view.endEditing(true)
        let size = CGSize(width: 40, height: 40)
        self.startAnimating(size, message: message, type: .circleStrokeSpin)
    }
    
    func dismissLoading() {
        self.stopAnimating()
    }
}
