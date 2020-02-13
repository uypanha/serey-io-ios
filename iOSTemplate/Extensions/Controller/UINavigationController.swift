//
//  UINavigationController.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
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
        if #available(iOS 13, *) {
            let standardAppearance = self.navigationBar.standardAppearance.copy()
            standardAppearance.backgroundColor = ColorName.navigationBg.color
            self.navigationBar.standardAppearance = standardAppearance
            
            let compactAppearance = self.navigationBar.compactAppearance?.copy()
            compactAppearance?.backgroundColor = ColorName.navigationBg.color
            self.navigationBar.compactAppearance = compactAppearance
            
            let scrollEdgeAppearance = self.navigationBar.scrollEdgeAppearance?.copy()
            scrollEdgeAppearance?.backgroundColor = ColorName.navigationBg.color
            self.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
        }
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
}
