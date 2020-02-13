//
//  AccountVIewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/12/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class AccountVIewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var followButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
    }
}

// MARK: - Preparations & Tools
extension AccountVIewController {
    
    func setUpViews() {
        self.profileContainerView.addBorders(edges: [.bottom], color: UIColor.lightGray.withAlphaComponent(0.2))
        prepareTableView()
    }
    
    func prepareTableView() {
        self.tableView.backgroundColor = ColorName.postBackground.color
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
    }
}
