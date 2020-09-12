//
//  BottomMenuViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 4/3/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import MaterialComponents

class BottomMenuViewController: MDCBottomSheetController {
    
    init(_ viewModel: BottomListMenuViewModel) {
        let listViewController = ListTableViewController(viewModel)
        listViewController.sepereatorStyle = .none
        listViewController.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        listViewController.view.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        super.init(contentViewController: listViewController)
        
        self.isScrimAccessibilityElement = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.dismissOnDraggingDownSheet = true
        self.trackingScrollView = listViewController.tableView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
