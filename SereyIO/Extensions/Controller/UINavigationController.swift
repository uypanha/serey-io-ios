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
        self.view.backgroundColor = ColorName.navigationBg.color
        self.setNavigationBarColor(ColorName.navigationBg.color, tintColor: ColorName.navigationTint.color)
    }
    
    func transparentNavigationBar() {
        self.removeNavigationBarBorder()
        self.setNavigationBarColor(.clear, tintColor: .white, isTransparent: true)
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.isTranslucent = true
    }
    
    func removeNavigationBarBorder() {
        self.navigationBar.shadowImage = UIImage()
        if #available(iOS 13.0, *) {
            let standardAppearance = self.navigationBar.standardAppearance.copy()
            standardAppearance.shadowColor = .clear
            standardAppearance.shadowImage = UIImage()
            self.navigationBar.standardAppearance = standardAppearance
            
            let compactAppearance = self.navigationBar.compactAppearance?.copy()
            compactAppearance?.shadowColor = .clear
            compactAppearance?.shadowImage = UIImage()
            self.navigationBar.compactAppearance = compactAppearance
            
            let scrollEdgeAppearance = self.navigationBar.scrollEdgeAppearance?.copy()
            scrollEdgeAppearance?.shadowColor = .clear
            scrollEdgeAppearance?.shadowImage = UIImage()
            self.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
        }
    }
    
    func showNavigationBarBorder() {
        self.navigationBar.shadowImage = UIColor.lightGray.withAlphaComponent(0.5).toImage()
        if #available(iOS 13.0, *) {
            let standardAppearance = self.navigationBar.standardAppearance.copy()
            standardAppearance.shadowColor = UIColor.lightGray.withAlphaComponent(0.5)
            standardAppearance.shadowImage = UIColor.lightGray.withAlphaComponent(0.5).toImage()
            self.navigationBar.standardAppearance = standardAppearance
            
            let compactAppearance = self.navigationBar.compactAppearance?.copy()
            compactAppearance?.shadowColor = UIColor.lightGray.withAlphaComponent(0.5)
            compactAppearance?.shadowImage = UIColor.lightGray.withAlphaComponent(0.5).toImage()
            self.navigationBar.compactAppearance = compactAppearance
            
            let scrollEdgeAppearance = self.navigationBar.scrollEdgeAppearance?.copy()
            scrollEdgeAppearance?.shadowColor = UIColor.lightGray.withAlphaComponent(0.5)
            scrollEdgeAppearance?.shadowImage = UIColor.lightGray.withAlphaComponent(0.5).toImage()
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
            self.navigationBar.scrollEdgeAppearance = standardAppearance
        } else if #available(iOS 11.0, *) {
            self.navigationBar.largeTitleTextAttributes = [
                .foregroundColor: tintColor,
                .font: UIFont.boldSystemFont(ofSize: 24)
            ]
        }
    }
}
