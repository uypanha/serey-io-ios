//
//  BottomSheetViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 8/10/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import MaterialComponents

class BottomSheetViewController: MDCBottomSheetController {

    init(contentViewController: UIViewController, preferredContentSize: CGSize? = nil){
        contentViewController.view.roundCorners(corners: [.topLeft, .topRight], radius: 16)
        super.init(contentViewController: contentViewController)
        
        self.isScrimAccessibilityElement = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.dismissOnDraggingDownSheet = true
        if let preferredContentSize = preferredContentSize {
            self.preferredContentSize = preferredContentSize
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
