//
//  MainViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 1/12/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    lazy var tableView: UITableView = UITableView()
    
    override func loadView() {
        super.loadView()
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpView()
    }
}

// MARK: - Preparations & Tools
extension MainViewController {
    
    func setUpView() {
        prepareTableView()
    }
    
    func prepareTableView() {
        self.tableView.tableFooterView = UIView()
    }
}
