//
//  LoadingButton.swift
//  SereyIO
//
//  Created by Panha Uy on 7/25/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoadingButton: UIButton {
    
    var originalButtonText: String?
    var activityIndicator: NVActivityIndicatorView!
    var isLoading: Bool {
        get {
            return !(self.activityIndicator?.isHidden ?? true)
        }
        set {
            newValue ? self.showLoading() : self.hideLoading()
        }
    }
    
    func showLoading() {
        originalButtonText = self.titleLabel?.text
        self.setTitle("", for: .normal)
        
        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator()
        }
        
        showSpinning()
    }
    
    func hideLoading() {
        self.setTitle(originalButtonText, for: .normal)
        activityIndicator?.stopAnimating()
        activityIndicator?.isHidden = true
    }
    
    private func createActivityIndicator() -> NVActivityIndicatorView {
        let height = self.frame.height * 0.5
        let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: height, height: height), type: .circleStrokeSpin, color: self.titleColor(for: .normal), padding: 0)
        return activityIndicator
    }
    
    private func showSpinning() {
        activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator?.isHidden = false
        self.addSubview(activityIndicator)
        centerActivityIndicatorInButton()
        activityIndicator?.startAnimating()
    }
    
    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
}
