//
//  UINavigationController.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        //  change to opaque all
        self.navigationBar.isTranslucent = false
        self.view.backgroundColor = UIColor.color(.navigationBg)
        self.setNavigationBarColor(.color(.navigationBg), tintColor: .color(.navigationTint))
    }
    
    func transparentNavigationBar() {
        self.removeNavigationBarBorder()
        self.setNavigationBarColor(.clear, tintColor: .white, isTransparent: true)
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.isTranslucent = true
    }
    
    func removeNavigationBarBorder() {
        let shadowImage = UIColor.clear.toImage()
        self.navigationBar.shadowImage = shadowImage
        
        if #available(iOS 13.0, *) {
            let standardAppearance = self.navigationBar.standardAppearance.copy()
            standardAppearance.shadowColor = .clear
            standardAppearance.shadowImage = shadowImage
            self.navigationBar.standardAppearance = standardAppearance
            
            let compactAppearance = self.navigationBar.compactAppearance?.copy()
            compactAppearance?.shadowColor = .clear
            compactAppearance?.shadowImage = shadowImage
            self.navigationBar.compactAppearance = compactAppearance
            
            let scrollEdgeAppearance = self.navigationBar.scrollEdgeAppearance?.copy()
            scrollEdgeAppearance?.shadowColor = .clear
            scrollEdgeAppearance?.shadowImage = shadowImage
            self.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
        }
    }
    
    func showNavigationBarBorder() {
        let shadowColor = UIColor.color(.border)
        let shadowImage = shadowColor.toImage()
        self.navigationBar.shadowImage = shadowImage
        
        if #available(iOS 13.0, *) {
            let standardAppearance = self.navigationBar.standardAppearance.copy()
            standardAppearance.shadowColor = shadowColor
            standardAppearance.shadowImage = shadowImage
            self.navigationBar.standardAppearance = standardAppearance
            
            let compactAppearance = self.navigationBar.compactAppearance?.copy()
            compactAppearance?.shadowColor = shadowColor
            compactAppearance?.shadowImage = shadowImage
            self.navigationBar.compactAppearance = compactAppearance
            
            let scrollEdgeAppearance = self.navigationBar.scrollEdgeAppearance?.copy()
            scrollEdgeAppearance?.shadowColor = shadowColor
            scrollEdgeAppearance?.shadowImage = shadowImage
            self.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
        }
    }
    
    func setNavigationBarColor(_ color: UIColor, tintColor: UIColor, isTransparent: Bool = false) {
        self.navigationBar.backgroundColor = color
        self.navigationBar.barTintColor = color
        self.navigationBar.tintColor = tintColor
        self.navigationBar.titleTextAttributes = [
            .foregroundColor: tintColor
        ]
        
        if #available(iOS 13, *) {
            let standardAppearance = self.navigationBar.standardAppearance.copy()
            if (isTransparent) { standardAppearance.configureWithTransparentBackground() }
            else { standardAppearance.configureWithOpaqueBackground() }
            standardAppearance.backgroundColor = color
            standardAppearance.titleTextAttributes = [
                .foregroundColor: tintColor,
                .font: UIFont.systemFont(ofSize: 17, weight: .medium)
            ]
            self.navigationBar.standardAppearance = standardAppearance
            
            let compactAppearance = self.navigationBar.compactAppearance?.copy()
            if (isTransparent) { compactAppearance?.configureWithTransparentBackground() }
            compactAppearance?.backgroundColor = color
            compactAppearance?.titleTextAttributes = [
                .foregroundColor: tintColor,
                .font: UIFont.systemFont(ofSize: 17, weight: .medium)
            ]
            self.navigationBar.compactAppearance = compactAppearance
            
            let scrollEdgeAppearance = self.navigationBar.scrollEdgeAppearance?.copy()
            if (isTransparent) { scrollEdgeAppearance?.configureWithTransparentBackground() }
            scrollEdgeAppearance?.backgroundColor = color
            scrollEdgeAppearance?.titleTextAttributes = [
                .foregroundColor: tintColor,
                .font: UIFont.systemFont(ofSize: 17, weight: .medium)
            ]
            if #available(iOS 15.0, *) {
                self.navigationBar.scrollEdgeAppearance = standardAppearance
            } else {
                self.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
            }
        } else if #available(iOS 11.0, *) {
            self.navigationBar.largeTitleTextAttributes = [
                .foregroundColor: tintColor,
                .font: UIFont.boldSystemFont(ofSize: 24)
            ]
        }
    }
}
