//
//  TransactionHistoryViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 7/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class TransactionHistoryViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.title = "Transaction History"
    }
}

// MARK: - Preparations & Tools
extension TransactionHistoryViewController {
    
    func setUpViews() {
        prepareTableView()
    }
    
    func prepareTableView() {
        self.tableView.separatorColor = ColorName.border.color
        self.tableView.tableFooterView = UIView()
    }
}
