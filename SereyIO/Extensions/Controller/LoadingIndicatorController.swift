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

//func showLoading(_ message: String? = nil) {
//    self.view.endEditing(true)
//    let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
//
//    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
//    loadingIndicator.hidesWhenStopped = true
//    loadingIndicator.style = UIActivityIndicatorView.Style.gray
//    loadingIndicator.startAnimating();
//
//    alert.view.addSubview(loadingIndicator)
//    loadingIndicator.snp.makeConstraints { make in
//        make.edges.equalToSuperview()
//    }
//    present(alert, animated: true, completion: nil)
//}
//
//func dismissLoading() {
//    dismiss(animated: true, completion: nil)
//}
