//
//  BottomMenuViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 4/3/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import MaterialComponents

class BottomMenuViewController: BottomSheetListViewController {
    
    init(_ viewModel: BottomListMenuViewModel) {
        let listViewController = MenuListTableViewController(viewModel)
        listViewController.sepereatorStyle = .none
        listViewController.contentInset = .init(top: 16, left: 0, bottom: 8, right: 0)
        listViewController.view.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        super.init(contentViewController: listViewController)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MenuListTableViewController: ListTableViewController<BottomListMenuViewModel> {
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as? UITableViewHeaderFooterView
        headerView?.contentView.backgroundColor = .white
        headerView?.textLabel?.textColor = .black
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
}
