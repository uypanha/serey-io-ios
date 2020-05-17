//
//  BottomSheetListViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 5/17/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import MaterialComponents

class BottomSheetListViewController: MDCBottomSheetController {

    init(contentViewController: UITableViewController){
        contentViewController.view.roundCorners(corners: [.topLeft, .topRight], radius: 8)
        super.init(contentViewController: contentViewController)
        
        self.isScrimAccessibilityElement = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.dismissOnDraggingDownSheet = true
        self.trackingScrollView = contentViewController.tableView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
