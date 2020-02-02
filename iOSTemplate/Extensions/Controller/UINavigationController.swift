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
        self.view.backgroundColor = UIColor.white
        if #available(iOS 13, *) {
            let standardAppearance = self.navigationBar.standardAppearance.copy()
            standardAppearance.backgroundColor = .white
            self.navigationBar.standardAppearance = standardAppearance
            
            let compactAppearance = self.navigationBar.compactAppearance?.copy()
            compactAppearance?.backgroundColor = .white
            self.navigationBar.compactAppearance = compactAppearance
            
            let scrollEdgeAppearance = self.navigationBar.scrollEdgeAppearance?.copy()
            scrollEdgeAppearance?.backgroundColor = .white
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
}
