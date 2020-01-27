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
    }
    
    func removeNavigationBarBorder() {
        self.navigationBar.shadowImage = UIImage()
    }
}
