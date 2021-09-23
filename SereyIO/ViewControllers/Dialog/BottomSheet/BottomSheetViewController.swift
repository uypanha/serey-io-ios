//
//  BottomSheetViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 8/10/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import MaterialComponents

class BottomSheetViewController: MDCBottomSheetController {

    override init(contentViewController: UIViewController){
        contentViewController.view.roundCorners(corners: [.topLeft, .topRight], radius: 16)
        super.init(contentViewController: contentViewController)
        
        self.isScrimAccessibilityElement = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.dismissOnDraggingDownSheet = true
        
        if contentViewController is UITableViewController {
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let preferredContentSize = (contentViewController as? BottomSheetProtocol)?.preferredBottomSheetContentSize {
            self.preferredContentSize = preferredContentSize
        }
    }
}
